use estudomysql;

drop function if exists numeroExtenso;
delimiter $$
create function numeroExtenso(valor double) returns varchar(255) deterministic
begin
	declare extenso varchar(255);
	declare valorMilhar, valorCentena, valorDezena, valorUnidade, valorCentavos double;
    
		if (valor < 0.01) then
			return null;
		end if;
        
        if (valor >= 1000000) then
			return null;
		end if;
        
        if (valor >= 1000) then	
			if (position("." in valor) > 0) then
				set valorCentavos := (valor - truncate(valor, 0)) * 100;
			end if;	
            
            set valorMilhar := truncate((valor/1000), 0);
			set valor := valor - (valorMilhar * 1000);
            
            set valorCentena := truncate((valor / 100), 0);
            set valor := valor - (valorCentena * 100);
            
            set valorDezena := truncate((valor / 10), 0);
            set valor := valor - (valorDezena * 10);
            
            set valorUnidade := truncate(valor,0);
            
            
            if (valorMilhar) then            
				set extenso := milhar(valorMilhar);
			end if;
            
           if (valorCentena) then
				if (valorCentena = 1 and (valorUnidade > 0 or valorDezena > 0)) then
					set extenso := concat(extenso, ", ", "cento");
				else
					set extenso := concat(extenso, ", ", centena(valorCentena)); 
				end if;
		   end if;
           
           if (valorDezena = 1 and valorUnidade > 0) then
				set extenso := concat(extenso, " e ", numeros(valorUnidade));
		   elseif (valorDezena > 0) then
				set extenso := concat(extenso, " e ", dezena(valorDezena)); 
		   end if;
           
           if (valorUnidade > 0 and not valorDezena and not valorCentena) then
				set extenso := concat(extenso, " e ", unidade(valorUnidade));
		   elseif (valorMilhar and valorCentena and not valorDezena and valorUnidade) then
				set extenso := concat(extenso, " e ", unidade(valorUnidade));
           elseif (valorUnidade > 0 and  (valorDezena > 0 and valorDezena != 1) and  valorCentena > 0) then
				set extenso := concat(extenso, " e ", unidade(valorUnidade));
		   elseif (valorUnidade > 0 and  (valorDezena > 0 and valorDezena != 1) and  not valorCentena) then
				set extenso := concat(extenso, " e ", unidade(valorUnidade));
		   else
				if (valorMilhar and valorCentena and valorDezena and valorUnidade) then
					set extenso := concat(extenso, " e ", unidade(valorUnidade));
				end if;
		   end if;	
           
           set extenso := concat(extenso, " ", "reais");
           
           if (valorCentavos > 0) then
				set extenso := concat(extenso, " e ", centavo(valorCentavos));
		   end if;
           
		   return extenso;   
			
        end if;	 
        
        
        if (valor >= 100 and valor < 1000) then
        
			if (position("." in valor) > 0) then
				set valorCentavos := (valor - truncate(valor, 0)) * 100;
			end if;	
            
            set valorCentena := truncate((valor / 100), 0);
            set valor := valor - (valorCentena * 100);
            
            set valorDezena := truncate((valor / 10), 0);
            set valor := valor - (valorDezena * 10);
            
            set valorUnidade := truncate(valor, 0);
            
            if (valorCentena) then
				if (valorCentena = 1 and (valorDezena or valorUnidade)) then
					set extenso := "cento";
				else
					set extenso := centena(valorCentena);
				end if;
            end if;
            
            if (valorDezena) then
				if (valorDezena = 1 and valorUnidade) then
					set extenso := concat(extenso, " e ", numeros(valorUnidade));
				else
					set extenso := concat(extenso, " e ", dezena(valorDezena));
				end if;
			end if;  
            
            if (valorUnidade and not valorDezena) then
				set extenso := concat(extenso, " e ", unidade(valorUnidade));
			elseif (valorUnidade and valorDezena and valorDezena != 1) then 
				set extenso := concat(extenso, " e ", unidade(valorUnidade));
			end if;
            
            set extenso := concat(extenso, " ", "reais");
            
            if (valorCentavos) then
				set extenso := concat(extenso, " e ", centavo(valorCentavos));
			end if;
            
            return extenso;           
             
            
        end if;
        
        if (valor < 100 and valor >= 1) then
			if (position("." in valor) > 0) then
				set valorCentavos := (valor - truncate(valor, 0)) * 100 ;
			end if;	
            
            set valorDezena := truncate((valor / 10), 0);
            set valor := valor - (valorDezena * 10);
            
            set valorUnidade := truncate(valor, 0);
            
           if (not valorDezena and valorUnidade) then
				set extenso := unidade(valorUnidade);			            
            elseif (valorDezena = 1 and valorUnidade) then
				set extenso := numeros(valorUnidade);
			elseif (valorDezena and not valorUnidade) then
				set extenso := dezena(valorDezena);
			else
				set extenso := concat(extenso, " e ", unidade(valorUnidade));
			end if; 
            
            if (not valorDezena and valorUnidade = 1) then
				set extenso := concat(extenso, " ", "real");
			else
				set extenso := concat(extenso, " ", "reais");
			end if;
            
            if (valorCentavos) then
				set extenso := concat(extenso, " e ", centavo(valorCentavos));
			end if;           
            
			
            return extenso;
        end if;
        
        if (valor < 1) then
			if (position("." in valor) > 0) then
				set valorCentavos := (valor - truncate(valor, 0)) * 100 ;
			end if;	
            
            set extenso := centavo(valorCentavos);
            
            return extenso;
		end if;	
			
		
			
end$$
delimiter ;

select numeroExtenso(8456.69);
select (1500.45 - truncate(1500.45, 0)) * 100;
drop function if exists milhar;
delimiter $$
create function milhar(valor integer) returns varchar(255) deterministic
begin
		declare extenso varchar(255);
        declare u , d, c integer;
        
        
        set c := truncate(substring_index(valor/100, ".", 1), 0);
        set d := left(mid(substring_index(valor/100, ".", -1), 1, 2), 1);
        set u := right(mid(substring_index(valor/100, ".", -1), 1, 2), 1);
        
		if (not c and not d and u > 0) then
			set extenso := unidade(u);
		elseif (not c and d = 1 and u > 0) then
			set extenso := numeros(u);
		elseif (not c and d > 0 and not u) then
			set extenso := dezena(d);
		elseif (not c and d > 0 and u > 0) then
			set extenso := concat_ws(" ", dezena(d), "e", unidade(u));
		elseif (c > 0 and not d and not u) then
			set extenso := centena(c);
		elseif (c > 0 and not d and u > 0) then
				if (c = 1 and u > 0) then
					set extenso := concat_ws(" ", "cento", "e", unidade(u));
				else
					set extenso := concat_ws(" ", centena(c), "e", unidade(u));
				end if;
			
		elseif (c > 0 and d > 0 and u = 0) then
			if (c = 1) then
				set extenso := concat_ws(" ", "cento", "e", dezena(d));
			else 
				set extenso := concat_ws(" ", centena(c), "e", dezena(d));
            end if;
		elseif (c > 0 and d > 0 and u > 0) then
			if (c = 1 and d = 1) then
				set extenso := concat_ws(" ", "cento", "e", numeros(u));
			elseif (c != 1 and d = 1) then
				set extenso := concat_ws(" ",centena(c),"e", numeros(u));
			elseif (c = 1 and d != 1) then
				set extenso := concat_ws(" ", "cento", "e", dezena(d), "e",unidade(u));
			else
				set extenso := concat_ws(" ", centena(c), "e", dezena(d), "e",unidade(u));
			end if;
		end if;
        
        return concat_ws(" ", extenso, "mil");
    
end$$
delimiter ;



select centavo(25);

drop function if exists centavo;
delimiter $$
create function centavo (valor integer) returns varchar(255) deterministic
begin
	declare extenso varchar(255);
	declare d integer;
    declare u integer;
	set d := round(left(substring_index(truncate((valor/100), 2), ".", -1), 1));
    set u := round(right(substring_index(truncate((valor/100), 2), ".", -1), 1));
    
		if (d = 1 and u > 0) then
			set extenso := numeros(u);
		
        elseif (d = 0 and u > 0) then
			set extenso := unidade(u);
		elseif (d > 0 and u > 0) then
			set extenso := concat_ws(" ",dezena(d),"e", unidade(u));
		else
			set extenso := dezena(d);
		end if;
        
        if (d = 0 and u = 1) then
			set extenso := concat_ws(" ", extenso, "centavo");
		else
			set extenso := concat_ws(" ", extenso, "centavos");
		end if;
					
    return extenso;
end$$

delimiter ;

select centavo(2);

select left(substring_index(truncate((1/100), 2), ".", -1), 1);

drop function if exists numeros;
delimiter $$
create  function numeros(valor integer) returns varchar(255) deterministic
begin
	declare extenso varchar(255) default "";
    
    if (valor = 0) then
		set extenso := " ";
	end if;
    
	case valor
		when 1 then
			set extenso = "onze";
		when 2 then
			set extenso = "doze";
		when 3 then
			set extenso = "treze";
		when 4 then
			set extenso = "quatoze";
		when 5 then
			set extenso = "quinze";
		when 6 then
			set extenso = "dezesseis";
		when 7 then
			set extenso = "dezessete";
		when 8 then
			set extenso = "dezoito";
		when 9 then
			set extenso = "dezenove";
		else
			set extenso := " ";
	end case;
    
    return extenso;

end$$
delimiter ;



drop function if exists unidade;
delimiter $$
create  function unidade(valor integer) returns varchar(255) deterministic
begin
	declare extenso varchar(255);
    
    if (valor = 0) then
		set extenso := " ";
	end if;
    
	case valor
		when 1 then
			set extenso = "um";
		when 2 then
			set extenso = "dois";
		when 3 then
			set extenso = "tres";
		when 4 then
			set extenso = "quatro";
		when 5 then
			set extenso = "cinco";
		when 6 then
			set extenso = "seis";
		when 7 then
			set extenso = "sete";
		when 8 then
			set extenso = "oito";
		when 9 then
			set extenso = "nove";
		else
			set extenso := " ";
	end case;
    
    return extenso;

end$$
delimiter ;

select unidade(9);

drop function if exists dezena;
delimiter $$
create  function dezena(valor integer) returns varchar(255) deterministic
begin
	declare extenso varchar(255) default "";
    if (valor = 0) then
		set extenso := " ";
	end if;
    
	case valor
		when 1 then
			set extenso = "dez";
		when 2 then
			set extenso = "vinte";
		when 3 then
			set extenso = "trinta";
		when 4 then
			set extenso = "quarenta";
		when 5 then
			set extenso = "cinquenta";
		when 6 then
			set extenso = "sescenta";
		when 7 then
			set extenso = "setenta";
		when 8 then
			set extenso = "oitenta";
		when 9 then
			set extenso = "noventa";
		else
			set extenso := " ";
	end case;
    
    return extenso;

end$$
delimiter ;

select dezena(10);


drop function if exists centenas;
delimiter $$
create function centena(valor integer) returns varchar(255) deterministic
begin
	declare extenso varchar(255);
    if (valor = 0) then
		set extenso := " ";
	end if;
    
	case valor
		when 1 then
			set extenso = "cem";
		when 2 then
			set extenso = "duzentos";
		when 3 then
			set extenso = "trezentos";
		when 4 then
			set extenso = "quatrocentos";
		when 5 then
			set extenso = "quinhentos";
		when 6 then
			set extenso = "seiscentos";
		when 7 then
			set extenso = "setecentos";
		when 8 then
			set extenso = "oitocentos";
		when 9 then
			set extenso = "novecentos";
		else
			set extenso := " ";
	end case;
    
    return extenso;

end$$
delimiter ;

select centena(0);

