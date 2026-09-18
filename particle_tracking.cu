#include <curand_kernel.h>
#include "gpu_maths.cuh"

#define c0 = 3e5
#define PI = 3.14

__device__ void init_random(curandState &state) {
    int idx =blockIdx.x * blockDim.x + threadIdx.x;
    curand_init(seed, idx, 0, &state)
}

__device__ void isotropic_scatter(curandState state, &vx, &vy &vz) {
    float r = c0*curand_uniform(&state);
    float theta = asinf(-1.0f + 2*curand_uniform(&state));
    float phi = 2*PI*curand_uniform(&state);

    spherical_to_cartesian(r, theta, phi, vx, vy, vz)
}

__global__ void transport() {
    
}