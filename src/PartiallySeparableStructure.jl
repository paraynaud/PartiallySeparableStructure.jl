module PartiallySeparableStructure

    greet() = print("Hello World!")


    function test_chemin( x :: T) where T <: Number
        if x > 5
            return 5
        else
            return 4
        end
    end

    export greet, test_chemin



end # module

test_chemin(5)
