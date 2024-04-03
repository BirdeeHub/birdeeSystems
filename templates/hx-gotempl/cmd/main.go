package main

import (
	"net/http"

	"github.com/a-h/templ"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"foodbar/views"
)

func HTML(c echo.Context, code int, cmp templ.Component) error {
	c.Response().Header().Set(echo.HeaderContentType, echo.MIMETextHTML)
	c.Response().Status = code
	return cmp.Render(c.Request().Context(), c.Response().Writer)
}

func main() {
	e := echo.New()
	e.Use(middleware.Logger())
	e.Use(echo.WrapMiddleware(func(hndl http.Handler) http.Handler {
		return templ.NewCSSMiddleware(hndl, views.StaticStyles...)
	}))

	e.Static("/images", "images")

	e.GET("/", func(c echo.Context) error {
		e.Logger.Print(c)
		return HTML(c, http.StatusOK, views.Homepage())
	})

	e.Logger.Fatal(e.Start(":42069"))
}
