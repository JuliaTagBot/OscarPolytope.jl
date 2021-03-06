matrix_for_polymake(x::Nemo.fmpz_mat) = Matrix{BigInt}(x)
matrix_for_polymake(x::Nemo.fmpq_mat) = Matrix{Rational{BigInt}}(x)
matrix_for_polymake(x::AbstractMatrix{<:Integer}) = x
matrix_for_polymake(x::AbstractMatrix{<:Rational{<:Integer}}) = x
matrix_for_polymake(x::Polymake.pm_MatrixAllocated{Polymake.pm_Rational}) = x
matrix_for_polymake(x::AbstractArray) = x

function augment(vec::AbstractVector, val)
   s = size(vec)
   res = similar(vec, (s[1]+1,))
   res[1] = val
   res[2:end] = vec
   return res
end

function augment(mat::AbstractMatrix, vec::AbstractVector)
   s = size(mat)
   res = similar(mat, (s[1], s[2]+1))
   res[:, 1] = vec
   res[:, 2:end] = mat
   return res
end

homogenize(vec::AbstractVector, val::Number=0) = augment(vec, val)
homogenize(mat::AbstractMatrix, val::Number=1) = augment(mat, fill(val, size(mat,1)))

dehomogenize(vec::AbstractVector) = vec[2:end]
dehomogenize(mat::AbstractMatrix) = mat[:, 2:end]

function property_is_computed(P::Polymake.pm_perl_ObjectAllocated, S::Symbol)
   pv = Polymake.internal_call_method("lookup", P, Any[string(S)])
   return nothing != Polymake.convert_from_property_value(pv)
end
function property_is_computed(HP::HomogeneousPolyhedron, S::Symbol)
   return property_is_computed(HP.polymakePolytope, S)
end
function property_is_computed(P::Polyhedron, S::Symbol)
   return property_is_computed(P.homogeneous_polyhedron, S)
end

function decompose_vdata(A::AbstractMatrix)
   ncols = size(A, 2)
   vertexIndices = Int[]
   rayIndices = Int[]
   for i=1:ncols
      if A[1, i] == 0
         push!(rayIndices, i)
      elseif A[1, i] == 1
         push!(vertexIndices, i)
      end
   end
   return (A[2:end, vertexIndices], A[2:end, rayIndices])
end

function decompose_hdata(A)
   (-A[:,2:end], A[:,1])
end
