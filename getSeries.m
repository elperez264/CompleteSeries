function numbers = getSeries(numbers)

    totalSquares = 10;
    initialnumbers = length(numbers)+1;

    dif = diff(numbers);
    sum = diff(dif);
    
    
    if isempty(find(sum) >0)
        %es progresión aritmetica

        r = dif(1);
        for i=initialnumbers:totalSquares
            numbers = [numbers numbers(i-1)+r];
        end
    else
        if dif == flip(dif)
            %Es un patron
            
            %es el mismo patron excepto el ultimo elemento puesto que ya se
            %ha "repetido"
            r = dif(2:end);
            j = 1;
            for i=initialnumbers:totalSquares
                numbers = [numbers numbers(i-1)+r(j)];

                j = j + 1;
                if(j > length(r))
                    j = 1;
                end
            end
        else
            %Es fibonacci
            for i=initialnumbers:totalSquares
                numbers = [numbers numbers(i-1)+numbers(i-2)];
            end
        end
    end

end