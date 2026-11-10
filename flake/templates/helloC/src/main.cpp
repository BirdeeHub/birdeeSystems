#include "next.h"
#include <iostream>

// using namespace std;

int main(int argc, char *argv[]) {
    std::cout << "Hello, world!" << std::endl;
    std::cout << "Hello, " << argv[1] << "!" << std::endl;
    std::cout << "Number of arguments: " << argc << std::endl;
    std::string tester = "test string";
    tester = tester + "!";
    std::cout << tester << std::endl;
    message("buttface");

    // Print each argument
    std::cout << "Arguments:" << std::endl;
    for (int i = 0; i < argc; ++i) {
        std::cout << "argv[" << i << "]: " << argv[i] << std::endl;
    }
    return 0;
}
