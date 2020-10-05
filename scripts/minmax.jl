using AlphaZero

depth = 5
gspec = AlphaZero.Examples.experiments["tictactoe"].gspec
computer = MinMax.Player(depth=depth, amplify_rewards=true, τ=0.2)
interactive!(gspec, computer, Human())