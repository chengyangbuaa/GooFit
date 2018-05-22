#include <goofit/Error.h>
#include <goofit/PDFs/ParameterContainer.h>
#include <goofit/PDFs/basic/ExpPdf.h>

namespace GooFit {

__device__ fptype device_Exp(fptype *evt, ParameterContainer &pc) {
    int id       = pc.getObservable(0);
    fptype alpha = pc.getParameter(0);
    fptype x     = evt[id];

    fptype ret = exp(alpha * x);

    pc.incrementIndex(1, 1, 0, 1, 1);

    return ret;
}

__device__ fptype device_ExpOffset(fptype *evt, ParameterContainer &pc) {
    int id   = pc.getObservable(0);
    fptype x = evt[id];
    x -= pc.getParameter(0);
    fptype alpha = pc.getParameter(1);

    fptype ret = exp(alpha * x);

    pc.incrementIndex(1, 2, 0, 1, 1);

    return ret;
}

__device__ fptype device_ExpPoly(fptype *evt, ParameterContainer &pc) {
    int id   = pc.getObservable(0);
    fptype x = evt[id];

    fptype exparg = 0;

    int np = pc.getNumParameters();
    for(int i = 0; i < np; ++i) {
        exparg += pow(x, i) * pc.getParameter(i);
    }

    fptype ret = exp(exparg);

    pc.incrementIndex(1, np, 0, 1, 1);

    return ret;
}

__device__ fptype device_ExpPolyOffset(fptype *evt, ParameterContainer &pc) {
    int id   = pc.getObservable(0);
    fptype x = evt[id];
    x -= pc.getParameter(0);

    fptype exparg = 0;

    int np = pc.getNumParameters();
    for(int i = 1; i < np; ++i) {
        exparg += pow(x, i) * pc.getParameter(i);
    }

    fptype ret = exp(exparg);

    pc.incrementIndex(1, np, 0, 1, 1);

    return ret;
}

__device__ device_function_ptr ptr_to_Exp           = device_Exp;
__device__ device_function_ptr ptr_to_ExpPoly       = device_ExpPoly;
__device__ device_function_ptr ptr_to_ExpOffset     = device_ExpOffset;
__device__ device_function_ptr ptr_to_ExpPolyOffset = device_ExpPolyOffset;

__host__ ExpPdf::ExpPdf(std::string n, Observable _x, Variable alpha, Variable offset)
    : GooPdf(n, _x) {
    registerParameter(offset);
    registerParameter(alpha);

    ExpType = 1;

    initialize();
}

__host__ ExpPdf::ExpPdf(std::string n, Observable _x, Variable alpha)
    : GooPdf(n, _x) {
    registerParameter(alpha);

    ExpType = 0;

    initialize();
}

__host__ ExpPdf::ExpPdf(std::string n, Observable _x, std::vector<Variable> &weights, Variable offset)
    : GooPdf(n, _x) {
    registerParameter(offset);

    if(weights.empty())
        throw GooFit::GeneralError("Weights are empty!");

    for(Variable &w : weights)
        registerParameter(w);

    ExpType = 3;

    initialize();
}

__host__ ExpPdf::ExpPdf(std::string n, Observable _x, std::vector<Variable> &weights)
    : GooPdf(n, _x) {
    if(weights.empty())
        throw GooFit::GeneralError("Weights are empty!");

    for(Variable &w : weights)
        registerParameter(w);

    ExpType = 2;

    initialize();
}

__host__ void ExpPdf::recursiveSetIndices() {
    if(ExpType == 0) {
        GOOFIT_RECURSIVE_SET_INDICIES(ptr_to_Exp);
    } else if(ExpType == 1) {
        GOOFIT_RECURSIVE_SET_INDICIES(ptr_to_ExpOffset);
    } else if(ExpType == 2) {
        GOOFIT_RECURSIVE_SET_INDICIES(ptr_to_ExpPoly);
    } else if(ExpType == 3) {
        GOOFIT_RECURSIVE_SET_INDICIES(ptr_to_ExpPolyOffset);
    }
}

__host__ fptype ExpPdf::integrate(fptype lo, fptype hi) const {
    fptype alpha = host_parameters[parametersIdx + 1];

    if(0 == alpha) {
        // This gives a constant 1 all across the range
        return (hi - lo);
    }

    fptype ret = exp(alpha * hi) - exp(alpha * lo);
    ret /= alpha;
    return ret;
}

} // namespace GooFit
