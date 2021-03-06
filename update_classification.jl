using CUTEst
import DataStructures: OrderedDict
using JSON

"""`update_classification()`

Creates the file `classf.json`, running each problem in `\$MASTSIF/CLASSF.DB` and
extracting the necessary information. It should be left alone, unless you think
it is not updated. If you do, please open an issue at
[https://github.com/JuliaSmoothOptimizers/CUTEst.jl](https://github.com/JuliaSmoothOptimizers/CUTEst.jl)
"""
function update_classification()
  newclassdb = readlines(joinpath(ENV["MASTSIF"], "CLASSF.DB"))
  oldclassdb = readlines("CLASSF.DB")
  if oldclassdb == newclassdb
    println("Nothing to do")
    return
  end

  list = sort(setdiff(newclassdb, oldclassdb) ∪ setdiff(oldclassdb, newclassdb))

  problems = OrderedDict(JSON.parse(open("classf.json")))

  for line in list
    sline = split(line)
    p = String(sline[1])
    cl = split(sline[2], "")

    print("Problem $p... ")
    nlp = CUTEstModel(p)
    try
      problems[p] = Dict(
          :objtype          => CUTEst.classdb_objtype[cl[1]],
          :contype          => CUTEst.classdb_contype[cl[2]],
          :regular          => cl[3] == "R",
          :derivative_order => Int(cl[4][1]-'0'),
          :origin           => CUTEst.classdb_origin[cl[6]],
          :has_internal_var => cl[7] == "Y",
          :variables        => Dict(
            :can_choose     => sline[3][1] == "V",
            :number         => nlp.meta.nvar,
            :fixed          => length(nlp.meta.ifix),
            :free           => length(nlp.meta.ifree),
            :bounded_below  => length(nlp.meta.ilow),
            :bounded_above  => length(nlp.meta.iupp),
            :bounded_both   => length(nlp.meta.irng)
          ),
          :constraints      => Dict(
            :can_choose     => sline[4][1] == "V",
            :number         => nlp.meta.ncon,
            :equality       => length(nlp.meta.jfix),
            :ineq_below     => length(nlp.meta.jlow),
            :ineq_above     => length(nlp.meta.jupp),
            :ineq_both      => length(nlp.meta.jrng),
            :linear         => nlp.meta.nlin,
            :nonlinear      => nlp.meta.nnln
          )
      )
      println("done")
    catch ex
      ex isa InterrupException && rethrow(ex)
      println("errored: $ex")
    finally
      finalize(nlp)
    end
  end
  sort!(problems)
  open("classf.json", "w") do jsonfile
    JSON.print(jsonfile, problems, 2)
  end
end

update_classification()
