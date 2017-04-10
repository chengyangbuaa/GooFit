#include <pybind11/pybind11.h>
#include <goofit/PDFs/ExpPdf.h>

namespace py = pybind11;

void init_ExpPdf(py::module &m) {
    py::class_<ExpPdf, GooPdf>(m, "ExpPdf")
        .def(py::init<std::string, Variable*, Variable*>())
        .def(py::init<std::string, Variable*, Variable*, Variable*>())
        ;
}