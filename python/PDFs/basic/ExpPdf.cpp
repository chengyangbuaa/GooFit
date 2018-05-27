#include <goofit/Python.h>

#include <goofit/PDFs/basic/ExpPdf.h>
#include <goofit/Variable.h>
#include <goofit/docs/PDFs/basic/ExpPdf.h>

using namespace GooFit;

void init_ExpPdf(py::module &m) {
    py::class_<ExpPdf, GooPdf>(m, "ExpPdf")
        .def(py::init<std::string, Observable, Variable>(), "A plain exponential.", "name"_a, "x"_a, "alpha"_a)

        .def(py::init<std::string, Observable, Variable, Variable>(),
             "A plain exponential.",
             "name"_a,
             "x"_a,
             "alpha"_a,
             "offset"_a)

        .def_static("help", []() { return HelpPrinter(ExpPdf_docs); });

    // TODO: add stl and missing constructors
}
