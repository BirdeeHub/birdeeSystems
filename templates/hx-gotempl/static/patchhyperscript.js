var parseRepeatExpression = function (
  parser,
  tokens,
  runtime,
  startedWithForToken,
) {
  var innerStartToken = tokens.currentToken();
  var identifier;
  if (tokens.matchToken("for") || startedWithForToken) {
    var identifierToken = tokens.requireTokenType("IDENTIFIER");
    identifier = identifierToken.value;
    tokens.requireToken("in");
    var expression = parser.requireElement("expression", tokens);
  } else if (tokens.matchToken("in")) {
    identifier = "it";
    var expression = parser.requireElement("expression", tokens);
  } else if (tokens.matchToken("while")) {
    var whileExpr = parser.requireElement("expression", tokens);
  } else if (tokens.matchToken("until")) {
    var isUntil = true;
    if (tokens.matchToken("event")) {
      var evt = parser.requireElement(
        "dotOrColonPath",
        tokens,
        "Expected event name",
      );
      if (tokens.matchToken("from")) {
        var on = parser.requireElement("expression", tokens);
      }
    } else {
      var whileExpr = parser.requireElement("expression", tokens);
    }
  } else {
    if (
      !parser.commandBoundary(tokens.currentToken()) &&
      tokens.currentToken().value !== "forever"
    ) {
      var times = parser.requireElement("expression", tokens);
      tokens.requireToken("times");
    } else {
      tokens.matchToken("forever"); // consume optional forever
      var forever = true;
    }
  }

  if (tokens.matchToken("index") || tokens.matchToken("by")) {
    var identifierToken = tokens.requireTokenType("IDENTIFIER");
    var indexIdentifier = identifierToken.value;
  } else if (tokens.matchToken("indexed")) {
    tokens.requireToken("by");
    var identifierToken = tokens.requireTokenType("IDENTIFIER");
    var indexIdentifier = identifierToken.value;
  }

  var loop = parser.parseElement("commandList", tokens);
  if (loop && evt) {
    // if this is an event based loop, wait a tick at the end of the loop so that
    // events have a chance to trigger in the loop condition o_O)))
    var last = loop;
    while (last.next) {
      last = last.next;
    }
    var waitATick = {
      type: "waitATick",
      op: function () {
        return new Promise(function (resolve) {
          setTimeout(function () {
            resolve(runtime.findNext(waitATick));
          }, 0);
        });
      },
    };
    last.next = waitATick;
  }
  if (tokens.hasMore()) {
    tokens.requireToken("end");
  }

  if (identifier == null) {
    identifier = "_implicit_repeat_" + innerStartToken.start;
    var slot = identifier;
  } else {
    var slot = identifier + "_" + innerStartToken.start;
  }

  var repeatCmd = {
    identifier: identifier,
    indexIdentifier: indexIdentifier,
    slot: slot,
    expression: expression,
    forever: forever,
    times: times,
    until: isUntil,
    event: evt,
    on: on,
    whileExpr: whileExpr,
    resolveNext: function () {
      return this;
    },
    loop: loop,
    args: [whileExpr, times],
    op: function (context, whileValue, times) {
      var iteratorInfo = context.meta.iterators[slot];
      var keepLooping = false;
      var loopVal = null;
      if (this.forever) {
        keepLooping = true;
      } else if (this.until) {
        if (evt) {
          keepLooping = context.meta.iterators[slot].eventFired === false;
        } else {
          keepLooping = whileValue !== true;
        }
      } else if (whileExpr) {
        keepLooping = whileValue;
      } else if (times) {
        keepLooping = iteratorInfo.index < times;
      } else {
        var nextValFromIterator = iteratorInfo.iterator.next();
        keepLooping = !nextValFromIterator.done;
        loopVal = nextValFromIterator.value;
      }

      if (keepLooping) {
        if (iteratorInfo.value) {
          context.result = context.locals[identifier] = loopVal;
        } else {
          context.result = iteratorInfo.index;
        }
        if (indexIdentifier) {
          context.locals[indexIdentifier] = iteratorInfo.index;
        }
        iteratorInfo.index++;
        return loop;
      } else {
        context.meta.iterators[slot] = null;
        return runtime.findNext(this.parent, context);
      }
    },
  };
  parser.setParent(loop, repeatCmd);
  var repeatInit = {
    name: "repeatInit",
    args: [expression, evt, on],
    op: function (context, value, event, on) {
      var iteratorInfo = {
        index: 0,
        value: value,
        eventFired: false,
      };
      context.meta.iterators[slot] = iteratorInfo;
      if (value && value[Symbol.iterator]) {
        iteratorInfo.iterator = value[Symbol.iterator]();
      }
      if (evt) {
        var target = on || context.me;
        target.addEventListener(
          event,
          function (e) {
            context.meta.iterators[slot].eventFired = true;
          },
          { once: true },
        );
      }
      return repeatCmd; // continue to loop
    },
    execute: function (context) {
      return runtime.unifiedExec(this, context);
    },
  };
  parser.setParent(repeatCmd, repeatInit);
  return repeatInit;
};

_hyperscript.addCommand("repeat", function (parser, runtime, tokens) {
  if (tokens.matchToken("repeat")) {
    return parseRepeatExpression(parser, tokens, runtime, false);
  }
});

_hyperscript.addCommand("for", function (parser, runtime, tokens) {
  if (tokens.matchToken("for")) {
    return parseRepeatExpression(parser, tokens, runtime, true);
  }
});
