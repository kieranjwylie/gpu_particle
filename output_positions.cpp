#include <fstream>
void output_positions(double *x, double *y, double *z, int N_particles, double time) {
    std::string timestep = std::to_string(time);
    std::ofstream file("positions_" + timestep + ".txt");
    
    for (int i = 0; i < N_particles; i++) {
        file << x[i] << " " << y[i] << " " << z[i] << std::endl;
    }
}