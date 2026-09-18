#include "input_parser.hpp"
#include <iostream>

YAML::Node open_yaml(const std::string& fname) {
    YAML::Node config = YAML::LoadFile(fname);
    return config;
}

template <typename T>
void read_setting(YAML::Node config, T &setting) {
    if (config) {
        setting = config.as<T>();
    }
}


void echo_settings(Settings settings) {
    std::cout << "Control settings:" << std::endl;
    std::cout << "  dt: " << settings.dt << " us" << std::endl;
    std::cout << "  Max time: " << settings.t_max << " us" << std::endl;
    std::cout << "  dt grow: " << settings.dt_grow << " us" << std::endl;
    std::cout << "  dt max: " << settings.dt_max << " us" << std::endl;
    std::cout << std::endl;

    std::cout << "Particle settings:" << std::endl;
    std::cout << "  Ensemble: " << settings.particles.ensemble << std::endl;
    std::cout << std::endl;

    std::cout << "Output settings:" << std::endl;
    std::cout << "  Output particle positions: " << settings.outputs.output_particle_positions << std::endl;
    std::cout << "  Echo settings: " << settings.outputs.echo_settings << std::endl<< std::endl;
}

void read_settings(const std::string& fname, Settings &settings) {
    YAML::Node config = open_yaml(fname);

    read_setting<double>(config["control"]["t_max"], settings.t_max);
    read_setting<double>(config["control"]["dt"], settings.dt);
    read_setting<double>(config["control"]["dt_grow"], settings.dt_grow);
    read_setting<double>(config["control"]["dt_max"], settings.dt_max);

    read_setting<int>(config["particles"]["ensemble"], settings.particles.ensemble);

    read_setting<bool>(config["output"]["output_particle_positions"], settings.outputs.output_particle_positions);
    read_setting<bool>(config["output"]["echo_settings"], settings.outputs.echo_settings);


    if (settings.outputs.echo_settings) {
        echo_settings(settings);
    }
}
