-- 1. Dla każdego zamówienia podaj łączną liczbę zamówionych jednostek towaru oraz nazwę klienta.

SELECT sum([O D].Quantity), C.CompanyName
FROM Orders
     LEFT JOIN [Order Details] [O D] on Orders.OrderID = [O D].OrderID
     LEFT JOIN Customers C on Orders.CustomerID = C.CustomerID
GROUP BY C.CustomerID, C.[CompanyName]

-- 2. Zmodyfikuj poprzedni przykład, aby pokazać tylko takie zamówienia, dla których łączna liczbę zamówionych jednostek jest większa niż 250

SELECT sum([O D].Quantity), C.CompanyName
FROM Orders
         LEFT JOIN [Order Details] [O D] on Orders.OrderID = [O D].OrderID
         LEFT JOIN Customers C on Orders.CustomerID = C.CustomerID
GROUP BY C.CustomerID, C.[CompanyName]
HAVING sum([O D].Quantity) > 250
ORDER BY sum([O D].Quantity) desc;

-- 3. Dla każdego zamówienia podaj łączną wartość tego zamówienia oraz nazwę klienta.

SELECT sum([O D].Quantity*[O D].UnitPrice *(1-[O D].Discount)) as SumPrice, C.CompanyName
FROM Orders
    LEFT JOIN [Order Details] [O D] on Orders.OrderID = [O D].OrderID
    LEFT JOIN Customers C on Orders.CustomerID = C.CustomerID
GROUP BY C.CustomerID, C.CompanyName
ORDER BY SumPrice desc;

-- 4. Zmodyfikuj poprzedni przykład, aby pokazać tylko takie zamówienia, dla których łączna liczba jednostek jest większa niż 250.


SELECT sum([O D].Quantity*[O D].UnitPrice *(1-[O D].Discount)) as SumPrice, C.CompanyName
FROM Orders
     LEFT JOIN [Order Details] [O D] on Orders.OrderID = [O D].OrderID
     LEFT JOIN Customers C on Orders.CustomerID = C.CustomerID
GROUP BY C.CustomerID, C.CompanyName
HAVING sum([O D].Quantity) > 250
ORDER BY SumPrice desc;

-- 5. Zmodyfikuj poprzedni przykład tak żeby dodać jeszcze imię i nazwisko pracownika obsługującego zamówienie

SELECT sum([O D].Quantity*[O D].UnitPrice *(1-[O D].Discount)) as SumPrice, C.CompanyName, CONCAT(E.FirstName,' ',E.LastName) as "employee"
FROM Orders
     LEFT JOIN [Order Details] [O D] on Orders.OrderID = [O D].OrderID
     LEFT JOIN Customers C on Orders.CustomerID = C.CustomerID
     LEFT JOIN Employees E on Orders.EmployeeID = E.EmployeeID
GROUP BY C.CustomerID, C.CompanyName, E.FirstName, E.LastName
HAVING sum([O D].Quantity) > 250
ORDER BY SumPrice desc;
