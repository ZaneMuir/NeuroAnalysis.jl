import NeuroAnalysis
using Base.test

@test NeuroAnalysis.helloworld() == "hello, world!"
@test NeuroAnalysis.helloagain() == "hey, bro!"