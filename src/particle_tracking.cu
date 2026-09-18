#include <curand_kernel.h>
#include <cuda_runtime.h>
#include "particle_tracking.cuh"

#define c0 29979.2
#define PI 3.14159265359

#include <iostream>

struct Particle {
   double *x;
   double *y;
   double *z; 
   
   double *vx;
   double *vy;
   double *vz;

   double *W;
   double *scattering_rate;

   bool *alive;
};

__device__ void init_random(curandState &state) {
    int idx =blockIdx.x * blockDim.x + threadIdx.x;
    curand_init(1234UL, idx, 0, &state);
}

__device__ void spherical_to_cartesian(double r, double theta, double phi, double &x, double &y, double &z) {
    x = r*sinf(theta)*cosf(phi);
    y = r*sinf(theta)*sinf(phi);
    z = r*cosf(theta);

}

__device__ void isotropic_scatter(curandState &state, double &vx, double &vy, double &vz) {
    double r = c0*curand_uniform(&state);
    double theta = acosf(-1.0f + 2*curand_uniform(&state));
    double phi = 2*PI*curand_uniform(&state);

    spherical_to_cartesian(r, theta, phi, vx, vy, vz);
}

__device__ void move(double t, double &x, double &y, double &z, double vx, double vy, double vz) {
    x += vx*t;
    y += vy*t;
    z += vz*t;
}

__device__ void init_position(double &x, double &y, double &z) {
    x = 0.0;
    y = 0.0;
    z = 0.0;
}

__device__ float free_flight_time(curandState &state, double scattering_rate) {
    return -log(curand_uniform(&state))/scattering_rate;
}

__global__ void transport(Particle particles, int N_particles, double dt) {

    int idx = idx =blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < N_particles) {

        double x = particles.x[idx];
        double y = particles.y[idx];
        double z = particles.z[idx];
        double vx = particles.vx[idx];
        double vy = particles.vy[idx];
        double vz = particles.vz[idx];
        double scattering_rate = particles.scattering_rate[idx];

        double clock = 0.0;

        curandState state;
        init_random(state);
        init_position(x, y, z);
        isotropic_scatter(state, vx, vy, vz);
        scattering_rate = 10000.0;

        while(clock < dt) {
            double t = free_flight_time(state, scattering_rate);
            move(t, x, y, z, vx, vy, vz);
            isotropic_scatter(state, vx, vy, vz);
            clock += t;
        }

        // Copy back to shared memory
        particles.x[idx] = x;
        particles.y[idx] = y;
        particles.z[idx] = z;
        particles.vx[idx] = vx;
        particles.vy[idx] = vy;
        particles.vz[idx] = vz;
        particles.scattering_rate[idx] = scattering_rate;
    }
}


void transport_loop(int ensemble, Settings settings) {

    int N = ensemble;

    Particle particles;

    cudaMalloc(&particles.x, N*sizeof(double));
    cudaMalloc(&particles.y, N*sizeof(double));
    cudaMalloc(&particles.z, N*sizeof(double));
    cudaMalloc(&particles.vx, N*sizeof(double));
    cudaMalloc(&particles.vy, N*sizeof(double));
    cudaMalloc(&particles.vz, N*sizeof(double));
    cudaMalloc(&particles.W, N*sizeof(double));
    cudaMalloc(&particles.scattering_rate, N*sizeof(double));
    cudaMalloc(&particles.alive, N*sizeof(bool));

    double time = 0.0;
    double dt = settings.dt;
    while (time < settings.t_max) {

        transport<<<128,128>>>(particles, N, dt);

        if (settings.outputs.output_particle_positions) {
            double* h_x = new double[N];
            double* h_y = new double[N];
            double* h_z = new double[N];
            cudaMemcpy(h_x, particles.x, N*sizeof(double), cudaMemcpyDeviceToHost);
            cudaMemcpy(h_y, particles.y, N*sizeof(double), cudaMemcpyDeviceToHost);
            cudaMemcpy(h_z, particles.z, N*sizeof(double), cudaMemcpyDeviceToHost);


            output_positions(h_x, h_y, h_z, N, time);
        }

        time += dt;
    }

    cudaFree(particles.x);
    cudaFree(particles.y);
    cudaFree(particles.z);
    cudaFree(particles.vx);
    cudaFree(particles.vy);
    cudaFree(particles.vz);
    cudaFree(particles.W);
    cudaFree(particles.W);
}