-- Ćwiczenie 1

--1. Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłki dostarczała firma United Package.

select distinct C.CompanyName, C.Phone
from Orders o
         join Customers C on o.CustomerID = C.CustomerID
         join Shippers S on o.ShipVia = S.ShipperID
where S.CompanyName = 'United Package'
  and year(o.ShippedDate) = 1997

select distinct CompanyName, Phone
from Orders
         join Customers on Orders.CustomerID = Customers.CustomerID
where year(ShippedDate) = 1997
  and ShipVia = (select ShipperID from Shippers where CompanyName = 'United Package')

select CompanyName, Phone
from Customers
where CustomerID in (select Orders.CustomerID
                     from Orders
                              join Shippers S
                                   on Orders.ShipVia = S.ShipperID and
                                      S.CompanyName = 'United Package'
                     where year(OrderDate) = '1997')

--2. Wybierz nazwy i numery telefonów klientów, którzy kupowali produkty z kategorii Confections.

select c.CompanyName, c.Phone
from Customers c
where c.CustomerID in (select distinct o.customerid
                       from Orders o
                                join [Order Details] od on o.OrderID = od.OrderID
                                join Products p on od.ProductID = p.ProductID
                                join Categories cat on p.CategoryID = cat.CategoryID
                       where cat.CategoryName = 'Confections')


--3. Wybierz nazwy i numery telefonów klientów, którzy nie kupowali produktów z kategorii Confections.

select c.CompanyName, c.Phone
from Customers c
where c.CustomerID not in (select distinct o.customerid
                           from Orders o
                                    join [Order Details] od on o.OrderID = od.OrderID
                                    join Products p on od.ProductID = p.ProductID
                                    join Categories cat on p.CategoryID = cat.CategoryID
                           where cat.CategoryName = 'Confections')

-- Ćwiczenie 2

-- 1. Dla każdego produktu podaj maksymalną liczbę zamówionych jednostek

select p.ProductName,
       (select max(od.Quantity) from [Order Details] od where od.ProductID = p.productid) as maxi
from Products p

-- 2. Podaj wszystkie produkty których cena jest mniejsza niż średnia cena produktu

select p.productid
from Products p
where p.UnitPrice < (select avg(p1.UnitPrice) as price from Products p1)

-- 3. Podaj wszystkie produkty których cena jest mniejsza niż średnia cena produktu danej kategorii


;
with srednie(categoryId, average) as (select p.CategoryId, avg(p.UnitPrice)
                                      from Products p
                                      group by p.CategoryId)

select s.*, p.UnitPrice, p.ProductName
from Products p
         join srednie s on s.categoryId = p.CategoryID
where s.average > p.UnitPrice

-- Ćwiczenie 3

-- 1. Dla każdego produktu podaj jego nazwę, cenę, średnią cenę wszystkich produktów oraz różnicę między ceną produktu a średnią ceną wszystkich produktów
;
with average(average) as
             (select avg(p.Unitprice) from Products p)

select p.productname, p.unitprice, a.average, p.unitprice - a.average as diff
from Products p
         join average a on 'a' = 'a'

-- 2. Dla każdego produktu podaj jego nazwę kategorii, nazwę produktu, cenę, średnią cenę wszystkich produktów danej kategorii oraz różnicę między ceną produktu a średnią ceną wszystkich produktów danej kategorii

;
with catAvg(categoryId, average, CategoryName) as (select p.CategoryId, avg(p.UnitPrice), C.CategoryName
                                                   from Products p
                                                            join Categories C on p.CategoryID = C.CategoryID
                                                   group by p.CategoryId, C.CategoryName)

select p.UnitPrice, p.ProductName, s.CategoryName, s.average, s.average - p.UnitPrice as diff
from Products p
         join catAvg s on s.categoryId = p.CategoryID

-- Ćwiczenie 4

-- 1. Podaj łączną wartość zamówienia o numerze 10250 (uwzględnij cenę za przesyłkę)

select sum((1 - od.Discount) * od.UnitPrice * od.Quantity) +
       (select o.Freight from Orders o where o.OrderID = od.OrderID) as suma,
       od.OrderID
from [Order Details] od
where od.OrderID = 10250
group by od.OrderID

-- 2. Podaj łączną wartość zamówień każdego zamówienia (uwzględnij cenę za przesyłkę)

select sum((1 - od.Discount) * od.UnitPrice * od.Quantity) +
       (select o.Freight from Orders o where o.OrderID = od.OrderID) as suma,
       od.OrderID
from [Order Details] od
group by od.OrderID

-- 3. Czy są jacyś klienci którzy nie złożyli żadnego zamówienia w 1997 roku, jeśli tak to pokaż ich dane adresowe

;
with klienci(id) as (select CustomerID from Orders where YEAR(ShippedDate) = 1997)

select CompanyName, City
from Customers
where CustomerID in (select id from klienci)


-- 4. Podaj produkty kupowane przez więcej niż jednego klienta

;
with orders_with_f(id) as (select ProductID from [Order Details] od group by ProductID having count(OrderID) > 1)

select *
from Products
where ProductID in (select id from orders_with_f)


-- Ćwiczenie 5

-- 1. Dla każdego pracownika (imię i nazwisko) podaj łączną wartość zamówień obsłużonych przez tego pracownika (przy obliczaniu wartości zamówień uwzględnij cenę za przesyłkę
;
with suma(id, suma) as (select od.OrderID,
                               sum((1 - od.Discount) * od.UnitPrice * od.Quantity) +
                               (select o.Freight from Orders o where o.OrderID = od.OrderID)
                        from [Order Details] od
                        group by od.OrderID)

select p.firstname, p.lastname, sum(suma.suma)
from Employees p
         join Orders o on p.EmployeeID = o.EmployeeID
         join suma on suma.id = o.OrderID
group by p.firstname, p.lastname

-- 2. Który z pracowników obsłużył najaktywniejszy (obsłużył zamówienia o największej wartości) w 1997r, podaj imię i nazwisko takiego pracownika

;
with sumaFiltered(id, suma) as (select od.OrderID,
                                       sum((1 - od.Discount) * od.UnitPrice * od.Quantity) + o.Freight
                                from [Order Details] od
                                         join Orders o on od.OrderID = o.OrderID and YEAR(o.ShippedDate) = 1997
                                group by od.OrderID, o.Freight)

select top 1 p.firstname, p.lastname, sum(suma.suma) as bestSuma
from Employees p
         join Orders o on p.EmployeeID = o.EmployeeID
         join sumaFiltered suma on suma.id = o.OrderID
group by p.firstname, p.lastname
order by bestSuma

-- 3. Ogranicz wynik z pkt 1 tylko do pracowników
-- a) którzy mają podwładnych
;
with suma(id, suma) as (select od.OrderID,
                               sum((1 - od.Discount) * od.UnitPrice * od.Quantity) +
                               (select o.Freight from Orders o where o.OrderID = od.OrderID)
                        from [Order Details] od
                        group by od.OrderID),
     podwladny(id) as (select e2.ReportsTo from Employees e2 where e2.ReportsTo is not NULL)

select p.firstname, p.lastname, sum(suma.suma)
from Employees p
         join Orders o on p.EmployeeID = o.EmployeeID
         join suma on suma.id = o.OrderID
where p.EmployeeID in (select id from podwladny)
group by p.firstname, p.lastname, p.EmployeeID


-- b) którzy nie mają podwładnych

;
with suma(id, suma) as (select od.OrderID,
                               sum((1 - od.Discount) * od.UnitPrice * od.Quantity) +
                               (select o.Freight from Orders o where o.OrderID = od.OrderID)
                        from [Order Details] od
                        group by od.OrderID),
     podwladny(id) as (select e2.ReportsTo from Employees e2 where e2.ReportsTo is not NULL)

select p.firstname, p.lastname, sum(suma.suma)
from Employees p
         join Orders o on p.EmployeeID = o.EmployeeID
         join suma on suma.id = o.OrderID
where p.EmployeeID not in (select id from podwladny)
group by p.firstname, p.lastname, p.EmployeeID

-- 4. Zmodyfikuj rozwiązania z pkt 3 tak aby dla pracowników pokazać jeszcze datę ostatnio obsłużonego zamówienia

-- z podwładnymi
;
with suma(id, suma) as (select od.OrderID,
                               sum((1 - od.Discount) * od.UnitPrice * od.Quantity) +
                               (select o.Freight from Orders o where o.OrderID = od.OrderID)
                        from [Order Details] od
                        group by od.OrderID),
     podwladny(id) as (select e2.ReportsTo from Employees e2 where e2.ReportsTo is not NULL)

select p.firstname,
       p.lastname,
       sum(suma.suma) as suma,
       (select top 1 o2.OrderDate
        from Orders o2
        where o2.EmployeeID = p.EmployeeID
        order by o2.OrderDate desc) as lastOrder
from Employees p
         join Orders o on p.EmployeeID = o.EmployeeID
         join suma on suma.id = o.OrderID
where p.EmployeeID in (select id from podwladny)
group by p.firstname, p.lastname, p.EmployeeID


-- z podwladnymi

;
with suma(id, suma) as (select od.OrderID,
                               sum((1 - od.Discount) * od.UnitPrice * od.Quantity) +
                               (select o.Freight from Orders o where o.OrderID = od.OrderID)
                        from [Order Details] od
                        group by od.OrderID),
     podwladny(id) as (select e2.ReportsTo from Employees e2 where e2.ReportsTo is not NULL)

select p.firstname,
       p.lastname,
       sum(suma.suma) as suma,
       (select top 1 o2.OrderDate
        from Orders o2
        where o2.EmployeeID = p.EmployeeID
        order by o2.OrderDate desc) as lastOrder
from Employees p
         join Orders o on p.EmployeeID = o.EmployeeID
         join suma on suma.id = o.OrderID
where p.EmployeeID not in (select id from podwladny)
group by p.firstname, p.lastname, p.EmployeeID
