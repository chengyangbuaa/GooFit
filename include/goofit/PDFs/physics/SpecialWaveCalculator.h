#pragma once

#include <goofit/PDFs/physics/DalitzPlotHelpers.h>
#include <goofit/PDFs/physics/MixingTimeResolution_Aux.h>

namespace GooFit {

class SpecialWaveCalculator : public thrust::unary_function<thrust::tuple<int, fptype *, int>, WaveHolder_s> {
  public:
    SpecialWaveCalculator(int pIdx, unsigned int res_idx);
    void setTddpIndex(unsigned int id) { tddp = id; }
    void setResonanceIndex(unsigned int id) { resonance_i = id; }
    __device__ WaveHolder_s operator()(thrust::tuple<int, fptype *, int> t) const;

  private:
    unsigned int tddp;
    unsigned int resonance_i;
    unsigned int parameters;
};

} // namespace GooFit
