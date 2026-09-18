
__device__ void spherical_to_cartesian(double r, double theta, double phi, double &x, double &y, double &z) {
    x = r*r*sinf(theta)*cosf(phi);
    y = r*r*sinf(theta)*sinf(phi);
    z = r*cosf(theta);

}