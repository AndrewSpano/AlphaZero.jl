module Tests

using Reexport
using Test

export run_all_tests

include("Common/Common.jl")
@reexport using .Common

include("NetworksTests.jl")
@reexport using .NetworksTests

include("BatchedEnvsTests.jl")
@reexport using .BatchedEnvsTests

include("EnvTests/BitwiseRandomWalk1DTests.jl")
@reexport using .BitwiseRandomWalk1DTests

include("EnvTests/BitwiseTicTacToeTests.jl")
@reexport using .BitwiseTicTacToeTests

include("EnvTests/BitwiseConnectFourTests.jl")
@reexport using .BitwiseConnectFourTests

include("UtilTests.jl")
@reexport using .UtilTests

include("MctsTests/SimpleMctsTests.jl")
@reexport using .SimpleMctsTests

include("MctsTests/BatchedMctsTests.jl")
@reexport using .BatchedMctsTests

include("MctsTests/BatchedMctsAosTests.jl")
@reexport using .BatchedMctsAosTests

function run_all_tests()
    @testset "RLZero tests" begin
        run_util_tests()
        run_neural_networks_tests()
        run_bitwise_random_walk_tests()
        run_bitwise_tictactoe_tests()
        run_bitwise_connect_four_tests()
        run_mcts_tests()
        run_batched_mcts_tests()
        run_batched_mcts_aos_tests()
    end
    return nothing
end

end
