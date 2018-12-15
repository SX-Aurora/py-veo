function test9(a, b, c, n, m) BIND(C)
    integer, dimension(n), intent(in) :: a
    integer, dimension(n) :: b
    double precision, intent(out) :: c(n,m)
    integer i, j, test9
    test9 = 0
    do i = 1, n
       test9 = test9 + a(i)
       b(i) = a(i) + 2
       do j = 1, m
          c(i,j) = dble(a(i)) * dble(j)
       end do
    end do
    !print *, arr
    !print *, "ftn finished."
    return
end

