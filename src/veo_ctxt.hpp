#ifndef _VEO_PY_VEO_CTXT_
#define _VEO_PY_VEO_CTXT_

#include <boost/python.hpp>
#include <vector>
#include <ve_offload.h>


using namespace boost::python;

namespace pyveo {

class PyVeoProc;
	
class PyVeoCtxt {
private:
	veo_thr_ctxt* thr_ctxt;
	veo_proc_handle *proc_handle;
public:
	PyVeoCtxt(veo_proc_handle *proc) : proc_handle(proc) {
		this->thr_ctxt = veo_context_open(proc);
		if (this->thr_ctxt == nullptr)
			PyErr_SetString(PyExc_RuntimeError, "veo_context_open failed");
	}

	~PyVeoCtxt() {
		veo_context_close(this->thr_ctxt);
	}

	uint64_t call_async(uint64_t addr, tuple args) {
		uint64_t res;
		veo_call_args ca;
		
		if (len(args) > 8)
			PyErr_SetString(PyExc_ValueError, "more than 8 arguments to VE function!");
		for (int i = 0; i < len(args); i++) {
			extract<long> elong(args[i]);
			if (elong.check()) {
				*((long *)&ca.arguments[i]) = elong();
				continue;
			}
			extract<int> eint(args[i]);
			if (eint.check()) {
				*((int *)&ca.arguments[i]) = eint();
				continue;
			}
			extract<double> edbl(args[i]);
			if (edbl.check()) {
				*((double *)&ca.arguments[i]) = edbl();
				continue;
			}
			extract<float> efloat(args[i]);
			if (efloat.check()) {
				*((float *)&ca.arguments[i]) = efloat();
				continue;
			}
			PyErr_SetString(PyExc_TypeError, "failed to cast argument");
		}
		res = veo_call_async(this->thr_ctxt, addr, &ca);
		if (res == VEO_REQUEST_ID_INVALID)
			PyErr_SetString(PyExc_RuntimeError, "veo_call_async failed");
		return res;
	}

	uint64_t call_wait_result(uint64_t reqid) {
		uint64_t res;
		int rc = veo_call_wait_result(this->thr_ctxt, reqid, &res);
		if (rc == -1)
			PyErr_SetString(PyExc_Exception, "call_wait_result command exception");
		else if (rc < 0)
			PyErr_SetString(PyExc_RuntimeError, "call_wait_result command error on VE");
		return res;
	}

	uint64_t call_peek_result(uint64_t reqid) {
		uint64_t res;
		int rc = veo_call_peek_result(this->thr_ctxt, reqid, &res);
		if (rc == -1)
			PyErr_SetString(PyExc_Exception, "call_peek_result command exception");
		else if (rc == -2)
			PyErr_SetString(PyExc_RuntimeError, "call_peek_result command error on VE");
		else if (rc == -3)
			PyErr_SetString(PyExc_NameError, "call_peek_result command unfinished");
		return res;
	}
};

} //namespace veo

void export_veo_ctxt();

#endif
