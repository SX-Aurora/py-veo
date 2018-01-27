#ifndef _VEO_PY_VEO_PROC_
#define _VEO_PY_VEO_PROC_

#include <boost/python.hpp>
#include <vector>
#include <ve_offload.h>
#include "veo_ctxt.hpp"

namespace pyveo {

class PyVeoProc {
private:
	veo_proc_handle* proc_handle;
public:
	PyVeoProc(int nodeid) : nodeid(nodeid) {
		this->proc_handle = veo_proc_create(nodeid);
		if (this->proc_handle == nullptr)
			PyErr_SetString(PyExc_RuntimeError, "veo_proc_create failed");
	}

	uint64_t load_library(const char *libname) {
		uint64_t res;
		res = veo_load_library(this->proc_handle, libname);
		if (res == 0UL)
			PyErr_SetString(PyExc_RuntimeError, "veo_load_library failed");
		return res;
	}

	uint64_t get_sym(uint64_t lib_handle, const char *symname) {
		uint64_t res;
		res = veo_get_sym(this->proc_handle, lib_handle, symname);
		if (res == 0UL)
			PyErr_SetString(PyExc_RuntimeError, "veo_get_sym failed");
		return res;
	}

	void read_mem(void *dst, uint64_t src, size_t size) {
		if (veo_read_mem(this->proc_handle, dst, src, size))
			PyErr_SetString(PyExc_RuntimeError, "veo_read_mem failed");
	}

	void write_mem(uint64_t dst, void *src, size_t size) {
		if (veo_write_mem(this->proc_handle, dst, src, size))
			PyErr_SetString(PyExc_RuntimeError, "veo_write_mem failed");
	}

	PyVeoCtxt *context_open() {
		PyVeoCtxt *c = new PyVeoCtxt(this->proc_handle);
		this->context.append(c);
		return c;
	}

	void context_close(PyVeoCtxt *c) {
		this->context.remove(c);
		delete c;
	}

	uint64_t get_proc() {
		return (uint64_t)this->proc_handle;
	}
	
	int nodeid;
	boost::python::list context;
};

} //namespace veo

void export_veo_proc();

#endif
