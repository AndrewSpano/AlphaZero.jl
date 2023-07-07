"""
    SimpleNetHP

Hyperparameters for the simplenet architecture.

| Parameter                     | Description                                  |
|:------------------------------|:---------------------------------------------|
| `width :: Int`                | Number of neurons on each dense layer        |
| `depth_common :: Int`         | Number of dense layers in the trunk          |
| `depth_phead = 1`             | Number of hidden layers in the actions head  |
| `depth_vhead = 1`             | Number of hidden layers in the value  head   |
| `use_batch_norm = false`      | Use batch normalization between each layer   |
| `batch_norm_momentum = 0.6f0` | Momentum of batch norm statistics updates    |
"""
@kwdef struct SimpleNetHP
  width :: Int
  depth_common :: Int
  depth_phead :: Int = 1
  depth_vhead :: Int = 1
  use_batch_norm :: Bool = false
  batch_norm_momentum :: Float32 = 0.6f0
end


"""
    SimpleNet <: FluxNetwork

A simple two-headed architecture with only dense layers.
"""
mutable struct SimpleNet <: FluxNetwork
    hyper
    common
    vhead
    phead
end
Flux.@functor SimpleNet (common, vhead, phead)


function SimpleNet(indim::Int, outdim::Int, hyper::SimpleNetHP)
    weight_init() = Flux.glorot_uniform(MersenneTwister(3409))

    function make_dense(indim, outdim)
        if hyper.use_batch_norm
            Flux.Chain(
                Flux.Dense(indim => outdim; init=weight_init()),
                Flux.BatchNorm(outdim, Flux.relu; momentum=hyper.batch_norm_momentum)
            )
        else
            Flux.Dense(indim => outdim, Flux.relu; init=weight_init())
        end
    end

    hlayers(depth) = [make_dense(hyper.width, hyper.width) for i in 1:depth]

    common = Flux.Chain(
        Flux.flatten,
        make_dense(indim, hyper.width),
        hlayers(hyper.depth_common)...
    )

    vhead = Flux.Chain(
        hlayers(hyper.depth_vhead)...,
        Flux.Dense(hyper.width => 1, tanh; init=weight_init())
    )

    phead = Flux.Chain(
        hlayers(hyper.depth_phead)...,
        Flux.Dense(hyper.width => outdim; init=weight_init()),
        Flux.softmax
    )

    SimpleNet(hyper, common, vhead, phead)
end


HyperParams(::Type{SimpleNet}) = SimpleNetHP
hyperparams(nn::SimpleNet) = nn.hyper
on_gpu(nn::SimpleNet) = arr_is_on_gpu(nn.vhead[end].bias)


function forward(nn::SimpleNet, x)
    common = nn.common(x)
    v = nn.vhead(common)
    p = nn.phead(common)
    return v, p
end