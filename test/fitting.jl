@testset "Fitting" begin
  TI = training_image("WalkerLake")[1:20,1:20,1]
  xwalker = Float64[i for i=1:20 for j=1:20]
  ywalker = Float64[j for i=1:20 for j=1:20]
  zwalker = Float64[TI[i,j] for i=1:20 for j=1:20]
  γwalker = EmpiricalVariogram(hcat(xwalker,ywalker)', zwalker, maxlag=15.)

  # variogram types to fit
  Vs = (GaussianVariogram, SphericalVariogram,
        ExponentialVariogram, MaternVariogram)

  # all fits lead to same sill
  γs = [Variography.fit(V, γwalker) for V in Vs]
  for γ in γs
    @test isapprox(sill(γ), 0.054, atol=1e-3)
  end

  # best fit is a Gaussian variogram
  γbest = Variography.fit(Variogram, γwalker)
  @test γbest isa GaussianVariogram
  @test isapprox(sill(γbest), 0.054, atol=1e-3)

  if visualtests
    @plottest begin
      plts = []
      for γ in γs
        plt = plot(γwalker, legend=false)
        plot!(γ, maxlag=15.)
        push!(plts, plt)
      end
      plot(plts...)
    end joinpath(datadir,"Fitting.png") !istravis
  end
end
