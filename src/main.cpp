
#include "particle_tracking.cuh"
#include "input_parser.hpp"
int main() {

    Settings settings;
    read_settings("hi.yaml", settings);

    transport_loop(settings.particles.ensemble, settings);
}