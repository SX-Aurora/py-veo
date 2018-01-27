#include "veo_ctxt.hpp"
#include "veo_proc.hpp"

using namespace pyveo;
using namespace boost::python;

void export_veo_proc()
{
	class_<PyVeoProc>("VeoProc", init<int>())
		.def("context_open", &PyVeoProc::context_open,
			return_value_policy<manage_new_object>())
		.def("context_close", &PyVeoProc::context_close)
		.def("get_proc", &PyVeoProc::get_proc)
		.def("get_sym", &PyVeoProc::get_sym)
		.def("load_library", &PyVeoProc::load_library)
		.def("read_mem", &PyVeoProc::read_mem)
		.def("write_mem", &PyVeoProc::write_mem)
		.def_readonly("context", &PyVeoProc::context)
		.def_readonly("nodeid", &PyVeoProc::nodeid)
		;
}
