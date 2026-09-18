#pragma once

#include "yaml-cpp/yaml.h"

struct Output_settings{
    bool output_particle_positions = false;
    bool echo_settings = false;
};

struct Particle_settings{
    int ensemble = 10000;
};


struct Settings {
    double dt = 1e-5;
    double dt_grow = 1.0;
    double dt_max = 1e-5;
    double t_max = 1.0;

    Particle_settings particles;

    Output_settings outputs;
};

void read_settings(const std::string& fname, Settings& settings);