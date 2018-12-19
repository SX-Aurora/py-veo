import os
from veo import *

bld = VeBuild()
bld.set_build_dir("_ve_build")
bld.set_c_src("_average", r"""
double average(double *a, int n)
{
    int i;
    double sum = 0;

    for (i = 0; i < n; i++)
        sum += a[i];

    return sum / (double)n;
}
""")

ve_so_name = bld.build_so()

# VE node to run on, take 0 as default
nodeid = os.environ.get("VE_NODE_NUMBER", 0)

proc = VeoProc(nodeid)
ctxt = proc.open_context()
lib = proc.load_library(os.getcwd() + "/" + ve_so_name)
lib.average.args_type("double *", "int")
lib.average.ret_type("double")

n = 1000000     # length of random vector: 1M elements
a = np.random.rand(n)
print("VH numpy average = %r" % np.average(a))

# submit VE function request
req = lib.average(ctxt, OnStack(a), n)

# wait for the request to finish
avg = req.wait_result()
print("VE kernel average = %r" % avg)

del proc
