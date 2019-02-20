module OscarPolytope

import LinearAlgebra, Markdown, Nemo, Polymake

export Polyhedron, DualPolyhedron, HomogenousPolyhedron

# export polyhedron, dual_polyhedron, homogenous_polyhedron,
       # boundary_points_matrix, inner_points_matrix
matrix_for_polymake(x::Nemo.fmpz_mat) = Matrix{BigInt}(x)
matrix_for_polymake(x::Nemo.fmpq_mat) = Matrix{Rational{BigInt}}(x)
matrix_for_polymake(x::AbstractMatrix{<:Integer}) = x
matrix_for_polymake(x::AbstractMatrix{<:Rational{<:Integer}}) = x

#here BigInt, Integer, (fmpz, fmpq) -> Rational
#     nf_elem quad real field: -> QuadraticExtension
#     float -> Float
#     mpfr, BigFloat -> AccurateFloat

@doc Markdown.doc"""
    HomogenousPolyhedron(A)

The homogenous polyhedron defined by the inequalities $ A x ≥ 0$.
"""
struct HomogenousPolyhedron #
    P::Polymake.pm_perl_ObjectAllocated
    boundedness::Symbol # Values: :unknown, :bounded, :unbounded
end
function HomogenousPolyhedron(P::Polymake.pm_perl_ObjectAllocated)
    HomogenousPolyhedron(P, :unknown)
end
function HomogenousPolyhedron(bA)
  p = Polymake.perlobj("Polytope<Rational>", INEQUALITIES=matrix_for_polymake(bA))
  return HomogenousPolyhedron(p)
end

function Base.show(io::IO, H::HomogenousPolyhedron)
    print(io, "Homogeneous polyhedron given by { x | A x ≥ 0 } where \n")
    print(io, "\nA = \n")
    Base.print_array(io, H.P.INEQUALITIES)
end

@doc Markdown.doc"""
    Polyhedron(A, b)

The (metric) polyhedron defined by

$$P(A,b) = \{ x |  Ax ≤ b \}.$$
"""

struct Polyhedron #a real polymake polyhedron
    homogenous_polyhedron::HomogenousPolyhedron
end
Polyhedron(A, b) = Polyhedron(HomogenousPolyhedron([b -A]))

function Base.show(io::IO, P::Polyhedron)
    ineq = P.homogenous_polyhedron.P.INEQUALITIES
    print(io, "Polyhedron given by { x | A x ≤ b } where \n")
    print(io, "\nA = \n")
    Base.print_array(io, -ineq[:,2:end])
    print(io, "\n\nb = \n")
    Base.print_array(io, ineq[:,1])
end

@doc Markdown.doc"""
    DualPolyhedron(A, c)

The (metric) polyhedron defined by

$$P^*(A,c) = \{ y | yA = c, y ≥ 0 \}.$$
"""
struct DualPolyhedron #a real polymake polyhedron
    homogenous_polyhedron::HomogenousPolyhedron
end
function DualPolyhedron(A, c)
    #here BigInt, Integer, (fmpz, fmpq) -> Rational
    #     nf_elem quad real field: -> QuadraticExtension
    #     float -> Float
    #     mpfr, BigFloat -> AccurateFloat
    #
    m, n = size(A)
    cA = matrix_for_polymake([c -LinearAlgebra.transpose(A)])
    nonnegative = [zeros(BigInt, m, 1)  LinearAlgebra.I]
    P_star = Polymake.perlobj("Polytope<Rational>", EQUATIONS=cA, INEQUALITIES=nonnegative)
    H = HomogenousPolyhedron(P_star)
    return DualPolyhedron(H)
end

function Base.show(io::IO, P::DualPolyhedron)
    ineq = P.homogenous_polyhedron.P.EQUATIONS
    print(io, "DualPolyhedron given by { y | yA = c, y ≥ 0 } where \n")
    print(io, "\nA = \n")
    Base.print_array(io, -transpose(ineq[:,2:end]))
    print(io, "\n\nc = \n")
    Base.print_array(io, ineq[:,1])
end


#
# #we don't have points yet, so I can only return the matrix.
# # the polyhedron is not homogenous, so I strip the 1st entry
# #TODO: since P is given by Ax <= b, should the "points" be rows or columns?
#
# @doc Markdown.doc"""
#     boundary_points_matrix(P::Polyhedron) -> fmpz_mat
# > Given a bounded polyhedron, return the coordinates of all integer points
# > its boundary as rows in a matrix.
# """
# function boundary_points_matrix(P::Polyhedron)
#   p = _polytope(P)
#   out = Polymake.give(p, "BOUNDARY_LATTICE_POINTS")
#   res = zero_matrix(FlintZZ, rows(out), cols(out)-1)
#   for i=1:rows(out)
#     @assert out[i,1] == 1
#     for j=1:cols(out)-1
#       res[i,j] = out[i, j+1]
#     end
#   end
#   return res
# end
#
# @doc Markdown.doc"""
#     inner_points_matrix(P::Polyhedron) -> fmpz_mat
# > Given a bounded polyhedron, return the coordinates of all integer points
# > in its interior as rows in a matrix.
# """
# function inner_points_matrix(P::Polyhedron)
#   p = _polytope(P)
#   out = Polymake.give(p, "INTERIOR_LATTICE_POINTS")
#   res = zero_matrix(FlintZZ, rows(out), cols(out)-1)
#   for i=1:rows(out)
#     @assert out[i,1] == 1
#     for j=1:cols(out)-1
#       res[i,j] = out[i, j+1]
#     end
#   end
#   return res
# end

#=
function polyhedron(V::Array{Point, 1}, C::Array{Point, 1}=Array{Point, 1}(UndefInitializer(), 0), L::Array{Point, 1} = Array{Point, 1}(UndefInitializer(), 0))# only for Homogeneous version; Other::Dict{String, Any} = Dict{String, Any}())
  d = Dict{String, Any}("INEQUALITIES" => bA)
#  for (k,v) = Other
#    d[k] = v
#  end

#  POINTS = [ 1 V; 0 C], INPUT_LINEALITIES = L
  p = Polymake.perlobj("Polytope<Rational>", d)
  P = Polyhedron(t)
  P.P = p
  return P
end

function polyhedron(V::MatElem, C::MatElem, L::MatElem)
end

function convex_hull(P::polyhedron, Q::Polyhedron)
end
function convex_hull(P::polyhedron, Q::Point)
end
+(P, Q)
intersect(P, Q)
product
join
free_sum

lattice_points
isbounded
isunbounded
lattice_points_generators
volume
isempty


=#
end # module
