-- Database: e_commerce

-- Cart id for unique carts
CREATE TABLE Cart(
	
        Cart_id VARCHAR(7) PRIMARY KEY
);

-- This table will have the unique customer and cart id and user address
CREATE TABLE Customer(
	
        Customer_id VARCHAR(6) NOT NULL PRIMARY KEY,
        Name VARCHAR(30) NOT NULL,
        Address TEXT NOT NULL,
        Pincode VARCHAR(6) NOT NULL,
        Phone_number_s VARCHAR(10) NOT NULL,
        Cart_id VARCHAR(7)  REFERENCES cart(Cart_id)
);



-- This table will store the payment details for the respective customer and cart
CREATE TABLE Payment(
	
        payment_id VARCHAR(7) NOT NULL PRIMARY KEY,
        payment_date DATE NOT NULL,
        Payment_type VARCHAR(10) NOT NULL,
        Customer_id VARCHAR(6) REFERENCES Customer(Customer_id),
        Cart_id VARCHAR(7) REFERENCES Cart(Cart_id),
        total_amount INT
);

-- Product table for product description along with its unique product id

CREATE TABLE Product(
        
		P_id VARCHAR(7) NOT NULL PRIMARY KEY,
		P_category VARCHAR(30),
		P_name VARCHAR(30),
		P_Size VARCHAR(2) NOT NULL,
        P_gender CHAR(1) NOT NULL,
        P_price INT NOT NULL,
        P_quantity INT NOT NULL
);

-- This table will store the items in a customers cart 
CREATE TABLE Cart_item(
	
        Quantity_wished INT NOT NULL,
        Date_Added DATE NOT NULL,
        Cart_id VARCHAR(7) REFERENCES Cart(Cart_id),
        P_id VARCHAR(7) REFERENCES Product(P_id),
		Customer_id VARCHAR(6) REFERENCES Customer(Customer_id),
		P_price INT
);

-- table for keeping the final payable amount 
CREATE TABLE payable(
	Customer_id VARCHAR(6) REFERENCES Customer(Customer_id),
	payable_amount int,
	Cart_id VARCHAR(7) REFERENCES Cart(Cart_id)
	
	
);

alter table Cart_item add purchased varchar(3) default 'NO';

-- inserting into tables
-- 5 carts 
insert into Cart values('crt1011'),('crt1012'),('crt1013'),('crt1014'),('crt1015');
-- 5 customers
insert into Customer values('cid101','Ravi Shah','G-453','632014',9893135876,'crt1011'),
						   ('cid102','Anupama Shah','A-453','622014',8893135876,'crt1012'),
						   ('cid103','Sakshi Shah','S-453','631014',7893135876,'crt1013'),
						   ('cid104','Akshi Shah','R-253','632024',9893135875,'crt1014'),
						   ('cid105','Sarthak Shah','T-553','632034',6893125876,'crt1015');

-- Product entries
insert into Product values('pid1001','Clothing','jeans','S','M',1000,10),
						  ('pid1002','Clothing','shirt','M','F',500,20),
						  ('pid1003','Footwear','Sneakers','L','M',2000,5),
						  ('pid1004','Electronics','Televsion','M','N',75000,2);

insert into Product values('pid1005','Clothing','dresses','S','F',1000,30);
-- Cart items
insert into Cart_item values(3,to_date('10-OCT-2021','dd-mon-yyyy'),'crt1011','pid1001','cid101',1000),
							(10,to_date('10-NOV-2021','dd-mon-yyyy'),'crt1012','pid1002','cid102',500),
							(3,to_date('10-OCT-2021','dd-mon-yyyy'),'crt1011','pid1003','cid101',2000),
							(5,to_date('10-DEC-2021','dd-mon-yyyy'),'crt1012','pid1005','cid102',1000);



-- Payment

insert into Payment values('pmt1001',to_date('10-OCT-2021','dd-mon-yyyy'),'online','cid101','crt1011',NULL);

SELECT * FROM Cart;
SELECT * FROM Customer;
SELECT * FROM Payment;
SELECT * FROM Product;
SELECT * FROM Cart_item;



-- details of products present in the cart
 select * from product where p_id in(
        select p_id from Cart_item where (Cart_id in (
            select Cart_id from Customer where Customer_id='cid101'
        ))
    and purchased='NO');
	

-- updating the total amount for a product in cart_item
	update Cart_item set p_price= quantity_wished* p_price;
	
-- Trigger to give discount on a product if the quantity is greater than 2 for that product
   CREATE OR REPLACE FUNCTION discount_function()
	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	AS
	$$
	DECLARE
		price_after int;
		BEGIN
			IF NEW.quantity_wished > 2 THEN
			price_after = old.p_price - (0.1 *(old.p_price));
			insert into payable (payable_amount,Cart_id,Customer_id) values (price_after,OLD.Cart_id,old.Customer_id);
			ELSE
			insert into payable (payable_amount,Cart_id,Customer_id) values (old.p_price,OLD.Cart_id,old.Customer_id);
			END IF;
			
 			RETURN NEW;
		END;
	$$


	CREATE OR REPLACE TRIGGER before_payment
	BEFORE UPDATE
	ON Cart_item
	FOR EACH ROW
		EXECUTE PROCEDURE discount_function();
	   

select * from Cart_item;
select * from payable;

update Cart_item set quantity_wished=4 where cart_id='crt1011' AND p_id='pid1001';
update Cart_item set quantity_wished=2 where cart_id='crt1012' AND p_id='pid1002';


--Trigger to delete a row in cart_item if a payment is made
CREATE OR REPLACE FUNCTION delete_item()
	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	AS
	$$
		BEGIN	
			 DELETE FROM Cart_item WHERE purchased='YES';
 			 RETURN NEW;
		END;
	$$


	CREATE OR REPLACE TRIGGER after_payment
	AFTER UPDATE
	ON Cart_item
	FOR EACH ROW
		EXECUTE PROCEDURE delete_item();


 update Cart_item set purchased='YES' where cart_id='crt1011' AND p_id='pid1001';

   
    