#include <goofit/PDFs/ParameterContainer.h>
#include <goofit/PDFs/basic/ExpGausPdf.h>

namespace GooFit {

__device__ fptype device_ExpGaus(fptype *evt, ParameterContainer &pc) {
    int id = pc.getObservable(0);

    fptype x     = evt[id];
    fptype mean  = pc.getParameter(0);
    fptype sigma = pc.getParameter(1);
    fptype alpha = pc.getParameter(2);

    fptype ret    = 0.5 * alpha;
    fptype exparg = ret * (2 * mean + alpha * sigma * sigma - 2 * x);
    fptype erfarg = (mean + alpha * sigma * sigma - x) / (sigma * 1.4142135623);

    ret *= exp(exparg);
    ret *= erfc(erfarg);

    pc.incrementIndex(1, 3, 0, 1, 1);

    return ret;
}

__device__ device_function_ptr ptr_to_ExpGaus = device_ExpGaus;

ExpGausPdf::ExpGausPdf(std::string n, Observable _x, Variable mean, Variable sigma, Variable tau)
    : GooPdf(n, _x) {
    registerParameter(mean);
    registerParameter(sigma);
    registerParameter(tau);

    initialize();
}

__host__ void ExpGausPdf::recursiveSetIndices() { GOOFIT_RECURSIVE_SET_INDICIES(ptr_to_ExpGaus); }

} // namespace GooFit
