
function analyseB_Nan(s )
    index = Int(s.index)
    index2 = 3 - index
    cpt_true = 0
    cpt_false = 0
    # my_and(x :: Bool, y :: Bool) =  x && y :: Bool
    my_or(x :: Bool, y :: Bool) =  x || y :: Bool
    isInf(x) = (x == Inf)
    #Nous regardons la structure du Hessien à la recherche de hessien élementaire qui ne sont pas bien défini
    for i in s.tpl_B[index].arr # 1: length(s.tpl_B[index].arr)
        # work_arr = s.tpl_B[index].arr
        work_arr = i.elmt_hess
        b = mapreduce(x -> isnan(x), my_or, work_arr)
        b2 = mapreduce(x -> isInf(x), my_or, work_arr)
        if b || b2
            cpt_true = cpt_true + 1
            @show i
        else
            cpt_false = cpt_false + 1
        end
    end
    #Nous regardons la structure du second Hessien à la recherche de hessien élementaire qui ne sont pas bien défini
    for i in s.tpl_B[index2].arr # 1: length(s.tpl_B[index].arr)
        # work_arr = s.tpl_B[index].arr
        work_arr = i.elmt_hess
        b = mapreduce(x -> isnan(x), my_or, work_arr)
        b2 = mapreduce(x -> isInf(x), my_or, work_arr)
        if b || b2
            cpt_true = cpt_true + 1
            @show i
        else
            cpt_false = cpt_false + 1
        end
    end
    @show cpt_true, cpt_false
    return cpt_true, cpt_false
end


function return_index(s)
    index = Int(s.index)
    index2 = 3 - index
    listNaN = Dict{Int64,Int64}()
    # listNaN = Vector{Int64}(zeros(Int64,length(s.tpl_B[index].arr)))
    cpt = 1
    # my_and(x :: Bool, y :: Bool) =  x && y :: Bool
    my_or(x :: Bool, y :: Bool) =  x || y :: Bool
    isInf(x) = (x == Inf)
    #Nous regardons la structure du Hessien à la recherche de hessien élementaire qui ne sont pas bien défini
    for i in 1: length(s.tpl_B[index].arr)
        # work_arr = s.tpl_B[index].arr
        work_arr = s.tpl_B[index].arr[i].elmt_hess
        b = mapreduce(x -> isnan(x), my_or, work_arr)
        b2 = mapreduce(x -> isInf(x), my_or, work_arr)
        if b || b2
            listNaN[cpt] = i
            cpt = cpt + 1
        end
    end

    return listNaN
end


function montrer_autre_indice(s,d)
    index = Int(s.index)
    index2 = 3 - index
    for i in d
        @show s.tpl_B[index2].arr[i[2]]
    end
end


using Test

analyseB_Nan(s )
list_defectueux = return_index(s)
montrer_autre_indice(s, list_defectueux)
@show list_defectueux

my_and(x :: Bool, y :: Bool) =  x && y :: Bool
my_or(x :: Bool, y :: Bool) =  x || y :: Bool
@test mapreduce(x -> isnan(x), my_and, s.grad) == false
@test mapreduce(x -> isnan(x), my_or, s.grad) == false



error("stop")
opB(s) = LinearOperators.LinearOperator(i, i, true, true, x -> PartiallySeparableStructure.product_matrix_sps(s.sps, s.tpl_B[Int(s.index)], x) )
B = opB(s)
Krylov.cg(B, - s.grad, radius = s.Δ)
Krylov.cg_lanczos(B, - s.grad)

sparseB = PartiallySeparableStructure.construct_Sparse_Hessian(s.sps,s.tpl_B[Int(s.index)])
Bplein = Array(sparseB)
@test Bplein' == Bplein
opB2 = LinearOperators.LinearOperator(i, i, true, true, x -> Bplein * x )
Krylov.cg(opB2, - s.grad, radius = s.Δ)
Krylov.cg_lanczos(opB2, - s.grad)
