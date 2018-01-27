#include "veo_ctxt.hpp"

using namespace pyveo;
using namespace boost::python;

void export_veo_ctxt()
{
	class_<PyVeoCtxt>("VeoCtxt", no_init)
		.def("call_async", &PyVeoCtxt::call_async)
		.def("call_wait_result", &PyVeoCtxt::call_wait_result)
		.def("call_peek_result", &PyVeoCtxt::call_peek_result)
		;
}
