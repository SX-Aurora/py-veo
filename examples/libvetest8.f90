function mod_buff(arr, res, n)
    integer, dimension(n), intent(in) :: arr
    integer, dimension(n), intent(out) :: res
    integer i, mod_buff
    mod_buff = 0
    do i = 1, n
       mod_buff = mod_buff + arr(i)
       res(i) = arr(i) + 2
    end do
    !print *, arr
    !print *, "ftn finished."
    return
end

