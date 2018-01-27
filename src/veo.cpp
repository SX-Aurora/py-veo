#include <boost/python.hpp>

#include <vector>
#include <ve_offload.h>

#include "veo_ctxt.hpp"
#include "veo_proc.hpp"

using namespace boost::python;

static str version = "0.1";
static str doc = "Python interface to VEO: Vector Engine Offloading";

BOOST_PYTHON_MODULE(veo)
{
	scope().attr("VERSION") = version;
	scope().attr("__doc__") = doc;
	export_veo_proc();
	export_veo_ctxt();
}
