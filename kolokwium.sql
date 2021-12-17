-- 1.

;
with all_ as (
    select e.EmployeeID, c.CustomerID, e.FirstName, e.LastName, c.CompanyName
    from Orders o
             left join Employees e on e.EmployeeID = o.EmployeeID
             left join Customers C on o.CustomerID = C.CustomerID
    where year(o.OrderDate) = 1997
    ),
     count_ as (
         select EmployeeID, CustomerID, FirstName, LastName, CompanyName, count(*) as suma
         from all_
         group by EmployeeID, CustomerID, FirstName, LastName, CompanyName
     )

select c.CompanyName,
       (select top 1 suma from count_ where count_.CompanyName = c.CompanyName order by suma desc) as suma,
       (select top 1 concat(firstname, ' ', lastname)
        from count_
        where c.CompanyName = count_.CompanyName
        order by suma desc) as 'employeeName'
from Customers c


--2.
;
with sum_per_order as (
    select sum(od.UnitPrice * (1 - od.Discount) * od.Quantity) + Freight as suma, 1 as cnt, o.OrderID
    from Orders o
             left join [Order Details] od on od.OrderID = o.OrderID
    where year(o.OrderDate) = 1997
      and month(o.OrderDate) = 2
    group by o.OrderID, Freight
)


select e.firstname, e.LastName, isNULL(sum(sp.cnt), 0) as cnt, isNULL(sum(sp.suma), 0) as suma
from Employees e
         left outer join Orders O2 on e.EmployeeID = O2.EmployeeID
         left join sum_per_order sp on sp.OrderID = o2.OrderID
group by e.firstname, e.EmployeeID, e.LastName


--3.
;
with adres_child as (
    select a.street, a.city, j.member_no, a.state, a.zip
    from juvenile j
             left join adult a on j.adult_member_no = a.member_no
),
     member_with_c as (
         select member_no
         from loanhist l
                  left join title t on l.title_no = t.title_no
         where year(in_date) = 2001
           and month(in_date) = 12
           and day(in_date) = 14
           and t.title = 'Walking'
     )

select m.firstname, m.lastname, ac.street, ac.city, ac.zip, ac.state
from member_with_c mc
         inner join juvenile j2 on mc.member_no = j2.member_no
         left join adres_child ac on mc.member_no = ac.member_no
