
#include "particle_tracking.cuh"
#include "input_parser.hpp"
#include <iostream>

struct Command_line_options{
    std::string input_filename = "config.yaml";
};

int command_line_input(const int argc, char *argv[], Command_line_options clo) {
    
    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];

        if (arg == "-i" || arg == "--input") {
            clo.input_filename = argv[++i];
        }

        else if (arg == "-h" || arg == "--help") {
            std::cout << "Options:" << std::endl <<
                         "   -i <value>    Set the YAML input file" << std::endl <<
                         "   -h            Produce this help message" << std::endl;
        }
        else {
            std::cerr << "Unkown argument: " << arg << std::endl;
            return -1;
        }
    }

    return 0;
}

int main(int argc, char *argv[]) {

    Command_line_options clo;
    command_line_input(argc, argv, clo);
    Settings settings;
    read_settings(clo.input_filename, settings);

    transport_loop(settings.particles.ensemble, settings);
}