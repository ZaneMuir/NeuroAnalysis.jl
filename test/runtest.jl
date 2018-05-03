import NeuroAnalysis
using Base.Test

@test NeuroAnalysis.helloworld() == "hello, world!"
@test NeuroAnalysis.helloagain() == "hey, bro!"