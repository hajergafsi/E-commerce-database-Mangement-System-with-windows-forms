--
-- PostgreSQL database dump
--

-- Dumped from database version 10.14
-- Dumped by pg_dump version 13.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: calculateOrderPrice(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."calculateOrderPrice"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	 DECLARE 
	 prc INTEGER ;
    BEGIN
        prc = (SELECT SM FROM (SELECT SUM(oi."price") as SM, o."order_id" ord_id FROM "public"."OrderItem" oi JOIN "public"."Order" o ON  o."order_id" = oi."order_id" GROUP BY o."order_id") as TB  WHERE "ord_id" = NEW."order_id") AS prc ; 
        UPDATE "public"."Order" SET "total_price" = prc WHERE "order_id" = NEW."order_id" ;
	    RETURN NEW ;
	END; 
	$$;


ALTER FUNCTION public."calculateOrderPrice"() OWNER TO postgres;

--
-- Name: calculatePriceItem(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."calculatePriceItem"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	 DECLARE
     BEGIN
	 NEW."price" := NEW."quantity" * (SELECT "UnitPrice" FROM "public"."Product" WHERE "product_id" = OLD."product_id" ) - NEW."discount" + (SELECT "shipping_price" FROM "public"."ShippingOptions" WHERE"shipping_id" = OLD."shipping_id") ;
	 RETURN NEW ;
	END; 
	$$;


ALTER FUNCTION public."calculatePriceItem"() OWNER TO postgres;

--
-- Name: setChildCatsToZero(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."setChildCatsToZero"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	 BEGIN
		  NEW."nmbr_categories" := 0 ;
		 RETURN NEW ;
	END; 
	$$;


ALTER FUNCTION public."setChildCatsToZero"() OWNER TO postgres;

--
-- Name: setDate(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."setDate"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	 DECLARE BEGIN
	 NEW."placed_at" := CURRENT_DATE ;
	 RETURN NEW ;
	END; 
	$$;


ALTER FUNCTION public."setDate"() OWNER TO postgres;

--
-- Name: setDatePayment(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."setDatePayment"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	 DECLARE BEGIN
	 NEW."processed_at" := CURRENT_DATE ;
	 RETURN NEW ;
	END; 
	$$;


ALTER FUNCTION public."setDatePayment"() OWNER TO postgres;

--
-- Name: setParentCategory(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."setParentCategory"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	 DECLARE BEGIN
	    NEW."parentCategory" := (SELECT "parentCategory_id" FROM "public"."Category" WHERE NEW."category_id" = "category_id") ;
	    RETURN NEW ;
	END; 
	$$;


ALTER FUNCTION public."setParentCategory"() OWNER TO postgres;

--
-- Name: setPayment(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."setPayment"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	 DECLARE 
	 ordId INT ;
	 BEGIN 
	 ordId := ( SELECT "order_id" FROM "public"."Order" WHERE "order_id"=NEW."order_id" )AS payId;
	 UPDATE "public"."Order" SET "payment_id" = NEW."payment_id" WHERE "order_id" = ordId ;
	 	 UPDATE "public"."Order" SET "payment_date" = NEW."processed_at" WHERE "order_id" = ordId ;
	 RETURN NEW ;
	END; 
	$$;


ALTER FUNCTION public."setPayment"() OWNER TO postgres;

--
-- Name: setToZero(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."setToZero"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	  NEW."nmbr_products" := 0 ;
	 RETURN NEW ;
	END; 
	$$;


ALTER FUNCTION public."setToZero"() OWNER TO postgres;

SET default_tablespace = '';

--
-- Name: BillingAddress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."BillingAddress" (
    address_id integer NOT NULL,
    customer_id integer NOT NULL,
    "billingAddress" character varying NOT NULL,
    city character varying NOT NULL,
    country_code character(3) NOT NULL,
    "postalCode" character(5) NOT NULL
);


ALTER TABLE public."BillingAddress" OWNER TO postgres;

--
-- Name: BillingAddress_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."BillingAddress_address_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."BillingAddress_address_id_seq" OWNER TO postgres;

--
-- Name: BillingAddress_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."BillingAddress_address_id_seq" OWNED BY public."BillingAddress".address_id;


--
-- Name: BillingAddress_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."BillingAddress_customer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."BillingAddress_customer_id_seq" OWNER TO postgres;

--
-- Name: BillingAddress_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."BillingAddress_customer_id_seq" OWNED BY public."BillingAddress".customer_id;


--
-- Name: Cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Cart" (
    cart_id integer NOT NULL,
    customer_id integer NOT NULL,
    items integer DEFAULT 0 NOT NULL,
    status character varying NOT NULL,
    total_price numeric DEFAULT 0
);


ALTER TABLE public."Cart" OWNER TO postgres;

--
-- Name: CartItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CartItem" (
    cart_id integer NOT NULL,
    product_id integer NOT NULL,
    added_at date NOT NULL,
    "shipping_id " integer NOT NULL,
    "total_price " numeric NOT NULL
);


ALTER TABLE public."CartItem" OWNER TO postgres;

--
-- Name: CartItem_cart_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."CartItem_cart_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."CartItem_cart_id_seq" OWNER TO postgres;

--
-- Name: CartItem_cart_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."CartItem_cart_id_seq" OWNED BY public."CartItem".cart_id;


--
-- Name: CartItem_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."CartItem_product_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."CartItem_product_id_seq" OWNER TO postgres;

--
-- Name: CartItem_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."CartItem_product_id_seq" OWNED BY public."CartItem".product_id;


--
-- Name: CartItem_shipping_id _seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."CartItem_shipping_id _seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."CartItem_shipping_id _seq" OWNER TO postgres;

--
-- Name: CartItem_shipping_id _seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."CartItem_shipping_id _seq" OWNED BY public."CartItem"."shipping_id ";


--
-- Name: Cart_cart_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Cart_cart_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Cart_cart_id_seq" OWNER TO postgres;

--
-- Name: Cart_cart_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Cart_cart_id_seq" OWNED BY public."Cart".cart_id;


--
-- Name: Cart_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Cart_customer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Cart_customer_id_seq" OWNER TO postgres;

--
-- Name: Cart_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Cart_customer_id_seq" OWNED BY public."Cart".customer_id;


--
-- Name: Category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Category" (
    category_id integer NOT NULL,
    "parentCategory_id" integer NOT NULL,
    name character varying NOT NULL,
    nmbr_products integer NOT NULL
);


ALTER TABLE public."Category" OWNER TO postgres;

--
-- Name: Category_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Category_category_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Category_category_id_seq" OWNER TO postgres;

--
-- Name: Category_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Category_category_id_seq" OWNED BY public."Category".category_id;


--
-- Name: Category_name _seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Category_name _seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Category_name _seq" OWNER TO postgres;

--
-- Name: Category_name _seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Category_name _seq" OWNED BY public."Category".name;


--
-- Name: Category_parentCategory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Category_parentCategory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Category_parentCategory_id_seq" OWNER TO postgres;

--
-- Name: Category_parentCategory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Category_parentCategory_id_seq" OWNED BY public."Category"."parentCategory_id";


--
-- Name: Country; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Country" (
    country_code character(3) NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public."Country" OWNER TO postgres;

--
-- Name: CreditCard; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CreditCard" (
    card_id integer NOT NULL,
    customer_id integer NOT NULL,
    "cardNumber" character(16) NOT NULL,
    "CVV" character(3) NOT NULL,
    expiration_date date NOT NULL
);


ALTER TABLE public."CreditCard" OWNER TO postgres;

--
-- Name: CreditCard_card_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."CreditCard_card_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."CreditCard_card_id_seq" OWNER TO postgres;

--
-- Name: CreditCard_card_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."CreditCard_card_id_seq" OWNED BY public."CreditCard".card_id;


--
-- Name: CreditCard_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."CreditCard_customer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."CreditCard_customer_id_seq" OWNER TO postgres;

--
-- Name: CreditCard_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."CreditCard_customer_id_seq" OWNED BY public."CreditCard".customer_id;


--
-- Name: Customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Customer" (
    user_id integer NOT NULL,
    name character varying NOT NULL,
    surname character varying NOT NULL,
    username character varying NOT NULL,
    email character varying NOT NULL,
    birthdate date,
    country character varying,
    state character varying,
    city character varying,
    phone character varying,
    password character varying NOT NULL,
    "postalCode" character varying,
    address character varying
);


ALTER TABLE public."Customer" OWNER TO postgres;

--
-- Name: Customer_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Customer_user_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Customer_user_id_seq" OWNER TO postgres;

--
-- Name: Customer_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Customer_user_id_seq" OWNED BY public."Customer".user_id;


--
-- Name: Order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Order" (
    order_id integer NOT NULL,
    customer_id integer NOT NULL,
    payment_id integer,
    total_price numeric DEFAULT 0 NOT NULL,
    "supplier_id " integer NOT NULL,
    "billingAddress" integer NOT NULL,
    "shippingAddress" integer NOT NULL,
    payment_date date,
    placed_at date
);


ALTER TABLE public."Order" OWNER TO postgres;

--
-- Name: OrderItem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OrderItem" (
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    price numeric NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    discount numeric DEFAULT 0,
    size numeric NOT NULL,
    color character varying NOT NULL,
    shipped_at date,
    delivered_at date,
    shipping_id integer NOT NULL
);


ALTER TABLE public."OrderItem" OWNER TO postgres;

--
-- Name: OrderItem_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."OrderItem_order_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."OrderItem_order_id_seq" OWNER TO postgres;

--
-- Name: OrderItem_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."OrderItem_order_id_seq" OWNED BY public."OrderItem".order_id;


--
-- Name: OrderItem_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."OrderItem_product_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."OrderItem_product_id_seq" OWNER TO postgres;

--
-- Name: OrderItem_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."OrderItem_product_id_seq" OWNED BY public."OrderItem".product_id;


--
-- Name: OrderItem_shipping_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."OrderItem_shipping_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."OrderItem_shipping_id_seq" OWNER TO postgres;

--
-- Name: OrderItem_shipping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."OrderItem_shipping_id_seq" OWNED BY public."OrderItem".shipping_id;


--
-- Name: Order_billingAddress_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Order_billingAddress_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Order_billingAddress_seq" OWNER TO postgres;

--
-- Name: Order_billingAddress_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Order_billingAddress_seq" OWNED BY public."Order"."billingAddress";


--
-- Name: Order_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Order_customer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Order_customer_id_seq" OWNER TO postgres;

--
-- Name: Order_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Order_customer_id_seq" OWNED BY public."Order".customer_id;


--
-- Name: Order_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Order_order_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Order_order_id_seq" OWNER TO postgres;

--
-- Name: Order_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Order_order_id_seq" OWNED BY public."Order".order_id;


--
-- Name: Order_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Order_payment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Order_payment_id_seq" OWNER TO postgres;

--
-- Name: Order_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Order_payment_id_seq" OWNED BY public."Order".payment_id;


--
-- Name: Order_shippingAddress_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Order_shippingAddress_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Order_shippingAddress_seq" OWNER TO postgres;

--
-- Name: Order_shippingAddress_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Order_shippingAddress_seq" OWNED BY public."Order"."shippingAddress";


--
-- Name: Order_supplier_id _seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Order_supplier_id _seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Order_supplier_id _seq" OWNER TO postgres;

--
-- Name: Order_supplier_id _seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Order_supplier_id _seq" OWNED BY public."Order"."supplier_id ";


--
-- Name: ParentCategory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ParentCategory" (
    name character varying NOT NULL,
    description character varying,
    nmbr_categories integer DEFAULT 0,
    category_id integer NOT NULL
);


ALTER TABLE public."ParentCategory" OWNER TO postgres;

--
-- Name: ParentCategory_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."ParentCategory_category_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."ParentCategory_category_id_seq" OWNER TO postgres;

--
-- Name: ParentCategory_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."ParentCategory_category_id_seq" OWNED BY public."ParentCategory".category_id;


--
-- Name: Payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Payment" (
    payment_id integer NOT NULL,
    order_id integer NOT NULL,
    card_id integer NOT NULL,
    type_id integer NOT NULL,
    state character varying DEFAULT '"not processed"'::character varying NOT NULL,
    processed_at date
);


ALTER TABLE public."Payment" OWNER TO postgres;

--
-- Name: PaymentMethod; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."PaymentMethod" (
    type_id integer NOT NULL,
    name character varying NOT NULL,
    supplier_id integer NOT NULL
);


ALTER TABLE public."PaymentMethod" OWNER TO postgres;

--
-- Name: PaymentMethod_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."PaymentMethod_supplier_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."PaymentMethod_supplier_id_seq" OWNER TO postgres;

--
-- Name: PaymentMethod_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."PaymentMethod_supplier_id_seq" OWNED BY public."PaymentMethod".supplier_id;


--
-- Name: PaymentMethod_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."PaymentMethod_type_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."PaymentMethod_type_id_seq" OWNER TO postgres;

--
-- Name: PaymentMethod_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."PaymentMethod_type_id_seq" OWNED BY public."PaymentMethod".type_id;


--
-- Name: Payment_card_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Payment_card_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Payment_card_id_seq" OWNER TO postgres;

--
-- Name: Payment_card_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Payment_card_id_seq" OWNED BY public."Payment".card_id;


--
-- Name: Payment_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Payment_order_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Payment_order_id_seq" OWNER TO postgres;

--
-- Name: Payment_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Payment_order_id_seq" OWNED BY public."Payment".order_id;


--
-- Name: Payment_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Payment_payment_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Payment_payment_id_seq" OWNER TO postgres;

--
-- Name: Payment_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Payment_payment_id_seq" OWNED BY public."Payment".payment_id;


--
-- Name: Payment_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Payment_type_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Payment_type_id_seq" OWNER TO postgres;

--
-- Name: Payment_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Payment_type_id_seq" OWNED BY public."Payment".type_id;


--
-- Name: Product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Product" (
    product_id integer NOT NULL,
    category_id integer NOT NULL,
    supplier_id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    "UnitPrice" numeric NOT NULL,
    discount numeric DEFAULT 0,
    "UnitsInStock" integer NOT NULL,
    picture character varying,
    ranking numeric,
    "parentCategory" integer
);


ALTER TABLE public."Product" OWNER TO postgres;

--
-- Name: Product_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Product_category_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Product_category_id_seq" OWNER TO postgres;

--
-- Name: Product_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Product_category_id_seq" OWNED BY public."Product".category_id;


--
-- Name: Product_parentCategory_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Product_parentCategory_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Product_parentCategory_seq" OWNER TO postgres;

--
-- Name: Product_parentCategory_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Product_parentCategory_seq" OWNED BY public."Product"."parentCategory";


--
-- Name: Product_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Product_product_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Product_product_id_seq" OWNER TO postgres;

--
-- Name: Product_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Product_product_id_seq" OWNED BY public."Product".product_id;


--
-- Name: Product_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Product_supplier_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Product_supplier_id_seq" OWNER TO postgres;

--
-- Name: Product_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Product_supplier_id_seq" OWNED BY public."Product".supplier_id;


--
-- Name: Shipper; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Shipper" (
    shipper_id integer NOT NULL,
    "CompanyName" character varying NOT NULL,
    phone character varying NOT NULL
);


ALTER TABLE public."Shipper" OWNER TO postgres;

--
-- Name: Shipper_shipper_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Shipper_shipper_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Shipper_shipper_id_seq" OWNER TO postgres;

--
-- Name: Shipper_shipper_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Shipper_shipper_id_seq" OWNED BY public."Shipper".shipper_id;


--
-- Name: ShippingAddress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ShippingAddress" (
    address_id integer NOT NULL,
    customer_id integer NOT NULL,
    "shipAddress" character varying NOT NULL,
    city character varying NOT NULL,
    country_code character(3) NOT NULL,
    "postalCode" character(5) NOT NULL
);


ALTER TABLE public."ShippingAddress" OWNER TO postgres;

--
-- Name: ShippingAddress_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."ShippingAddress_address_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."ShippingAddress_address_id_seq" OWNER TO postgres;

--
-- Name: ShippingAddress_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."ShippingAddress_address_id_seq" OWNED BY public."ShippingAddress".address_id;


--
-- Name: ShippingAddress_customer_id _seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."ShippingAddress_customer_id _seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."ShippingAddress_customer_id _seq" OWNER TO postgres;

--
-- Name: ShippingAddress_customer_id _seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."ShippingAddress_customer_id _seq" OWNED BY public."ShippingAddress".customer_id;


--
-- Name: ShippingOptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ShippingOptions" (
    shipping_id integer NOT NULL,
    supplier_id integer NOT NULL,
    shipper_id integer NOT NULL,
    product_id integer NOT NULL,
    shipping_price numeric NOT NULL,
    country_code character(3) NOT NULL
);


ALTER TABLE public."ShippingOptions" OWNER TO postgres;

--
-- Name: ShippingOptions_product_id _seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."ShippingOptions_product_id _seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."ShippingOptions_product_id _seq" OWNER TO postgres;

--
-- Name: ShippingOptions_product_id _seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."ShippingOptions_product_id _seq" OWNED BY public."ShippingOptions".product_id;


--
-- Name: ShippingOptions_shipper_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."ShippingOptions_shipper_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."ShippingOptions_shipper_id_seq" OWNER TO postgres;

--
-- Name: ShippingOptions_shipper_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."ShippingOptions_shipper_id_seq" OWNED BY public."ShippingOptions".shipper_id;


--
-- Name: ShippingOptions_shipping_id _seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."ShippingOptions_shipping_id _seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."ShippingOptions_shipping_id _seq" OWNER TO postgres;

--
-- Name: ShippingOptions_shipping_id _seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."ShippingOptions_shipping_id _seq" OWNED BY public."ShippingOptions".shipping_id;


--
-- Name: ShippingOptions_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."ShippingOptions_supplier_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."ShippingOptions_supplier_id_seq" OWNER TO postgres;

--
-- Name: ShippingOptions_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."ShippingOptions_supplier_id_seq" OWNED BY public."ShippingOptions".supplier_id;


--
-- Name: Supplier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Supplier" (
    supplier_id integer NOT NULL,
    "CompanyName" character varying,
    "firstName" character varying NOT NULL,
    "lastName" character varying NOT NULL,
    address character varying,
    city character varying,
    country character varying,
    "postalCode" character varying,
    phone character varying,
    email character varying NOT NULL
);


ALTER TABLE public."Supplier" OWNER TO postgres;

--
-- Name: Supplier_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Supplier_supplier_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Supplier_supplier_id_seq" OWNER TO postgres;

--
-- Name: Supplier_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Supplier_supplier_id_seq" OWNED BY public."Supplier".supplier_id;


--
-- Name: BillingAddress address_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BillingAddress" ALTER COLUMN address_id SET DEFAULT nextval('public."BillingAddress_address_id_seq"'::regclass);


--
-- Name: BillingAddress customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BillingAddress" ALTER COLUMN customer_id SET DEFAULT nextval('public."BillingAddress_customer_id_seq"'::regclass);


--
-- Name: Cart cart_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cart" ALTER COLUMN cart_id SET DEFAULT nextval('public."Cart_cart_id_seq"'::regclass);


--
-- Name: Cart customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cart" ALTER COLUMN customer_id SET DEFAULT nextval('public."Cart_customer_id_seq"'::regclass);


--
-- Name: CartItem cart_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartItem" ALTER COLUMN cart_id SET DEFAULT nextval('public."CartItem_cart_id_seq"'::regclass);


--
-- Name: CartItem product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartItem" ALTER COLUMN product_id SET DEFAULT nextval('public."CartItem_product_id_seq"'::regclass);


--
-- Name: CartItem shipping_id ; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartItem" ALTER COLUMN "shipping_id " SET DEFAULT nextval('public."CartItem_shipping_id _seq"'::regclass);


--
-- Name: Category category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Category" ALTER COLUMN category_id SET DEFAULT nextval('public."Category_category_id_seq"'::regclass);


--
-- Name: Category parentCategory_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Category" ALTER COLUMN "parentCategory_id" SET DEFAULT nextval('public."Category_parentCategory_id_seq"'::regclass);


--
-- Name: CreditCard card_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCard" ALTER COLUMN card_id SET DEFAULT nextval('public."CreditCard_card_id_seq"'::regclass);


--
-- Name: CreditCard customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCard" ALTER COLUMN customer_id SET DEFAULT nextval('public."CreditCard_customer_id_seq"'::regclass);


--
-- Name: Customer user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customer" ALTER COLUMN user_id SET DEFAULT nextval('public."Customer_user_id_seq"'::regclass);


--
-- Name: Order order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order" ALTER COLUMN order_id SET DEFAULT nextval('public."Order_order_id_seq"'::regclass);


--
-- Name: Order customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order" ALTER COLUMN customer_id SET DEFAULT nextval('public."Order_customer_id_seq"'::regclass);


--
-- Name: Order supplier_id ; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order" ALTER COLUMN "supplier_id " SET DEFAULT nextval('public."Order_supplier_id _seq"'::regclass);


--
-- Name: Order billingAddress; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order" ALTER COLUMN "billingAddress" SET DEFAULT nextval('public."Order_billingAddress_seq"'::regclass);


--
-- Name: Order shippingAddress; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order" ALTER COLUMN "shippingAddress" SET DEFAULT nextval('public."Order_shippingAddress_seq"'::regclass);


--
-- Name: OrderItem shipping_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItem" ALTER COLUMN shipping_id SET DEFAULT nextval('public."OrderItem_shipping_id_seq"'::regclass);


--
-- Name: ParentCategory category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ParentCategory" ALTER COLUMN category_id SET DEFAULT nextval('public."ParentCategory_category_id_seq"'::regclass);


--
-- Name: Payment payment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment" ALTER COLUMN payment_id SET DEFAULT nextval('public."Payment_payment_id_seq"'::regclass);


--
-- Name: Payment order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment" ALTER COLUMN order_id SET DEFAULT nextval('public."Payment_order_id_seq"'::regclass);


--
-- Name: Payment card_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment" ALTER COLUMN card_id SET DEFAULT nextval('public."Payment_card_id_seq"'::regclass);


--
-- Name: Payment type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment" ALTER COLUMN type_id SET DEFAULT nextval('public."Payment_type_id_seq"'::regclass);


--
-- Name: PaymentMethod type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PaymentMethod" ALTER COLUMN type_id SET DEFAULT nextval('public."PaymentMethod_type_id_seq"'::regclass);


--
-- Name: PaymentMethod supplier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PaymentMethod" ALTER COLUMN supplier_id SET DEFAULT nextval('public."PaymentMethod_supplier_id_seq"'::regclass);


--
-- Name: Product product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product" ALTER COLUMN product_id SET DEFAULT nextval('public."Product_product_id_seq"'::regclass);


--
-- Name: Product category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product" ALTER COLUMN category_id SET DEFAULT nextval('public."Product_category_id_seq"'::regclass);


--
-- Name: Product supplier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product" ALTER COLUMN supplier_id SET DEFAULT nextval('public."Product_supplier_id_seq"'::regclass);


--
-- Name: Product parentCategory; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product" ALTER COLUMN "parentCategory" SET DEFAULT nextval('public."Product_parentCategory_seq"'::regclass);


--
-- Name: Shipper shipper_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Shipper" ALTER COLUMN shipper_id SET DEFAULT nextval('public."Shipper_shipper_id_seq"'::regclass);


--
-- Name: ShippingAddress address_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingAddress" ALTER COLUMN address_id SET DEFAULT nextval('public."ShippingAddress_address_id_seq"'::regclass);


--
-- Name: ShippingAddress customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingAddress" ALTER COLUMN customer_id SET DEFAULT nextval('public."ShippingAddress_customer_id _seq"'::regclass);


--
-- Name: ShippingOptions shipping_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingOptions" ALTER COLUMN shipping_id SET DEFAULT nextval('public."ShippingOptions_shipping_id _seq"'::regclass);


--
-- Name: ShippingOptions supplier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingOptions" ALTER COLUMN supplier_id SET DEFAULT nextval('public."ShippingOptions_supplier_id_seq"'::regclass);


--
-- Name: ShippingOptions shipper_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingOptions" ALTER COLUMN shipper_id SET DEFAULT nextval('public."ShippingOptions_shipper_id_seq"'::regclass);


--
-- Name: ShippingOptions product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingOptions" ALTER COLUMN product_id SET DEFAULT nextval('public."ShippingOptions_product_id _seq"'::regclass);


--
-- Name: Supplier supplier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Supplier" ALTER COLUMN supplier_id SET DEFAULT nextval('public."Supplier_supplier_id_seq"'::regclass);


--
-- Data for Name: BillingAddress; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."BillingAddress" (address_id, customer_id, "billingAddress", city, country_code, "postalCode") VALUES
	(1, 1, '07 rue des jammins', 'Paris', 'FRA', '54321'),
	(2, 11, '07 rue des jammins', 'Paris', 'FRA', '54321'),
	(3, 13, 'street of potato ', 'Chicago', 'USA', '98741'),
	(4, 14, 'street of cringe ', 'Washington', 'USA', '20145'),
	(5, 15, 'street of go ', 'Baku', 'AZE', '68541'),
	(6, 16, 'street of Washington ', 'Tunis', 'TUN', '7000 ');


--
-- Data for Name: Cart; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: CartItem; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: Category; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Category" (category_id, "parentCategory_id", name, nmbr_products) VALUES
	(4, 3, 'trousers', 2),
	(2, 5, 'laptops', 5),
	(5, 2, 'tops', 10),
	(6, 7, 'sneakers', 20),
	(25, 3, 'Shirts', 2),
	(1, 5, 'smartphones', 6);


--
-- Data for Name: Country; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Country" (country_code, name) VALUES
	('AFG', 'Afghanistan'),
	('ALA', 'AlandIslands'),
	('ALB', 'Albania'),
	('DZA', 'Algeria'),
	('ASM', 'AmericanSamoa'),
	('AND', 'Andorra'),
	('AGO', 'Angola'),
	('AIA', 'Anguilla'),
	('ATA', 'Antarctica'),
	('ATG', 'AntiguaandBarbuda'),
	('ARG', 'Argentina'),
	('ARM', 'Armenia'),
	('ABW', 'Aruba'),
	('AUS', 'Australia'),
	('AUT', 'Austria'),
	('AZE', 'Azerbaijan'),
	('BHS', 'Bahamas'),
	('BHR', 'Bahrain'),
	('BGD', 'Bangladesh'),
	('BRB', 'Barbados'),
	('BLR', 'Belarus'),
	('BEL', 'Belgium'),
	('BLZ', 'Belize'),
	('BEN', 'Benin'),
	('BMU', 'Bermuda'),
	('BTN', 'Bhutan'),
	('BOL', 'Bolivia'),
	('BES', 'Bonaire,SintEustatiusandSaba'),
	('BIH', 'BosniaandHerzegovina'),
	('BWA', 'Botswana'),
	('BVT', 'Bouvet Island'),
	('BRA', 'Brazil'),
	('IOT', 'British Indian Ocean Territory'),
	('BRN', 'Brunei Darussalam'),
	('BGR', 'Bulgaria'),
	('BFA', 'Burkina Faso'),
	('BDI', 'Burundi'),
	('KHM', 'Cambodia'),
	('CMR', 'Cameroon'),
	('CAN', 'Canada'),
	('CPV', 'Cape Verde'),
	('CYM', 'Cayman Islands'),
	('CAF', 'Central African Republic'),
	('TCD', 'Chad'),
	('CHL', 'Chile'),
	('CHN', 'China'),
	('CXR', 'Christmas Island'),
	('CCK', 'Cocos(Keeling)Islands'),
	('COL', 'Colombia'),
	('COM', 'Comoros'),
	('COG', 'Congo'),
	('COD', 'Congo,the Democratic Republic of the'),
	('COK', 'CookIslands'),
	('CRI', 'CostaRica'),
	('CIV', 'Cote D`Ivoire'),
	('HRV', 'Croatia'),
	('CUB', 'Cuba'),
	('CUW', 'Curacao'),
	('CYP', 'Cyprus'),
	('CZE', 'Czech Republic'),
	('DNK', 'Denmark'),
	('DJI', 'Djibouti'),
	('DMA', 'Dominica'),
	('DOM', 'Dominican Republic'),
	('ECU', 'Ecuador'),
	('EGY', 'Egypt'),
	('SLV', 'El Salvador'),
	('GNQ', 'Equatorial Guinea'),
	('ERI', 'Eritrea'),
	('EST', 'Estonia'),
	('ETH', 'Ethiopia'),
	('FLK', 'Falkland Islands(Malvinas)'),
	('FRO', 'FaroeIslands'),
	('FJI', 'Fiji'),
	('FIN', 'Finland'),
	('FRA', 'France'),
	('GUF', 'French Guiana'),
	('PYF', 'French Polynesia'),
	('ATF', 'French Southern Territories'),
	('GAB', 'Gabon'),
	('GMB', 'Gambia'),
	('GEO', 'Georgia'),
	('DEU', 'Germany'),
	('GHA', 'Ghana'),
	('GIB', 'Gibraltar'),
	('GRC', 'Greece'),
	('GRL', 'Greenland'),
	('GRD', 'Grenada'),
	('GLP', 'Guadeloupe'),
	('GUM', 'Guam'),
	('GTM', 'Guatemala'),
	('GGY', 'Guernsey'),
	('GIN', 'Guinea'),
	('GNB', 'Guinea-Bissau'),
	('GUY', 'Guyana'),
	('HTI', 'Haiti'),
	('HMD', 'Heard Islandand Mcdonald Islands'),
	('VAT', 'HolySee(VaticanCityState)'),
	('HND', 'Honduras'),
	('HKG', 'HongKong'),
	('HUN', 'Hungary'),
	('ISL', 'Iceland'),
	('IND', 'India'),
	('IDN', 'Indonesia'),
	('IRN', 'Iran,Islamic Republic of'),
	('IRQ', 'Iraq'),
	('IRL', 'Ireland'),
	('IMN', 'IsleofMan'),
	('ISR', 'Israel'),
	('ITA', 'Italy'),
	('JAM', 'Jamaica'),
	('JPN', 'Japan'),
	('JEY', 'Jersey'),
	('JOR', 'Jordan'),
	('KAZ', 'Kazakhstan'),
	('KEN', 'Kenya'),
	('KIR', 'Kiribati'),
	('PRK', 'Korea,Democratic People"s Republicof'),
	('KOR', 'Korea,Republicof'),
	('XKX', 'Kosovo'),
	('KWT', 'Kuwait'),
	('KGZ', 'Kyrgyzstan'),
	('LAO', 'Lao People`s Democratic Republic'),
	('LVA', 'Latvia'),
	('LBN', 'Lebanon'),
	('LSO', 'Lesotho'),
	('LBR', 'Liberia'),
	('LBY', 'Libyan Arab Jamahiriya'),
	('LIE', 'Liechtenstein'),
	('LTU', 'Lithuania'),
	('LUX', 'Luxembourg'),
	('MAC', 'Macao'),
	('MKD', 'Macedonia,theFormer Yugoslav Republic of'),
	('MDG', 'Madagascar'),
	('MWI', 'Malawi'),
	('MYS', 'Malaysia'),
	('MDV', 'Maldives'),
	('MLI', 'Mali'),
	('MLT', 'Malta'),
	('MHL', 'Marshall Islands'),
	('MTQ', 'Martinique'),
	('MRT', 'Mauritania'),
	('MUS', 'Mauritius'),
	('MYT', 'Mayotte'),
	('MEX', 'Mexico'),
	('FSM', 'Micronesia,Federated States of'),
	('MDA', 'Moldova,Republicof'),
	('MCO', 'Monaco'),
	('MNG', 'Mongolia'),
	('MNE', 'Montenegro'),
	('MSR', 'Montserrat'),
	('MAR', 'Morocco'),
	('MOZ', 'Mozambique'),
	('MMR', 'Myanmar'),
	('NAM', 'Namibia'),
	('NRU', 'Nauru'),
	('NPL', 'Nepal'),
	('NLD', 'Netherlands'),
	('ANT', 'Netherlands Antilles'),
	('NCL', 'New Caledonia'),
	('NZL', 'New Zealand'),
	('NIC', 'Nicaragua'),
	('NER', 'Niger'),
	('NGA', 'Nigeria'),
	('NIU', 'Niue'),
	('NFK', 'Norfolk Island'),
	('MNP', 'Northern Mariana Islands'),
	('NOR', 'Norway'),
	('OMN', 'Oman'),
	('PAK', 'Pakistan'),
	('PLW', 'Palau'),
	('PSE', 'Palestinian Territory,Occupied'),
	('PAN', 'Panama'),
	('PNG', 'PapuaNewGuinea'),
	('PRY', 'Paraguay'),
	('PER', 'Peru'),
	('PHL', 'Philippines'),
	('PCN', 'Pitcairn'),
	('POL', 'Poland'),
	('PRT', 'Portugal'),
	('PRI', 'PuertoRico'),
	('QAT', 'Qatar'),
	('REU', 'Reunion'),
	('ROM', 'Romania'),
	('RUS', 'Russian Federation'),
	('RWA', 'Rwanda'),
	('BLM', 'Saint Barthelemy'),
	('SHN', 'Saint Helena'),
	('KNA', 'Saint KittsandNevis'),
	('LCA', 'Saint Lucia'),
	('MAF', 'Saint Martin'),
	('SPM', 'Saint Pierre and Miquelon'),
	('VCT', 'Saint Vincent and the Grenadines'),
	('WSM', 'Samoa'),
	('SMR', 'SanMarino'),
	('STP', 'Sao Tome and Principe'),
	('SAU', 'Saudi Arabia'),
	('SEN', 'Senegal'),
	('SRB', 'Serbia'),
	('SCG', 'Serbia and Montenegro'),
	('SYC', 'Seychelles'),
	('SLE', 'SierraLeone'),
	('SGP', 'Singapore'),
	('SXM', 'Sint Maarten'),
	('SVK', 'Slovakia'),
	('SVN', 'Slovenia'),
	('SLB', 'Solomon Islands'),
	('SOM', 'Somalia'),
	('ZAF', 'SouthAfrica'),
	('SGS', 'South Georgia and the South Sandwich Islands'),
	('SSD', 'SouthSudan'),
	('ESP', 'Spain'),
	('LKA', 'SriLanka'),
	('SDN', 'Sudan'),
	('SUR', 'Suriname'),
	('SJM', 'Svalbardand JanMayen'),
	('SWZ', 'Swaziland'),
	('SWE', 'Sweden'),
	('CHE', 'Switzerland'),
	('SYR', 'Syrian Arab Republic'),
	('TWN', 'Taiwan,Province of China'),
	('TJK', 'Tajikistan'),
	('TZA', 'Tanzania,United Republic of'),
	('THA', 'Thailand'),
	('TLS', 'Timor-Leste'),
	('TGO', 'Togo'),
	('TKL', 'Tokelau'),
	('TON', 'Tonga'),
	('TTO', 'Trinidad and Tobago'),
	('TUN', 'Tunisia'),
	('TUR', 'Turkey'),
	('TKM', 'Turkmenistan'),
	('TCA', 'Turksand Caicos Islands'),
	('TUV', 'Tuvalu'),
	('UGA', 'Uganda'),
	('UKR', 'Ukraine'),
	('ARE', 'United Arab Emirates'),
	('GBR', 'United Kingdom'),
	('USA', 'United States'),
	('UMI', 'United States Minor Outlying Islands'),
	('URY', 'Uruguay'),
	('UZB', 'Uzbekistan'),
	('VUT', 'Vanuatu'),
	('VEN', 'Venezuela'),
	('VNM', 'VietNam'),
	('VGB', 'Virgin Islands,British'),
	('VIR', 'Virgin Islands,U.s.'),
	('WLF', 'Wallisand Futuna'),
	('ESH', 'Western Sahara'),
	('YEM', 'Yemen');
INSERT INTO public."Country" (country_code, name) VALUES
	('ZMB', 'Zambia'),
	('ZWE', 'Zimbabwe');


--
-- Data for Name: CreditCard; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."CreditCard" (card_id, customer_id, "cardNumber", "CVV", expiration_date) VALUES
	(1, 1, '5131530665913726', '513', '2023-10-13'),
	(2, 11, '4024007104653315', '422', '2023-12-27'),
	(3, 12, '4532799623021991', '508', '2028-02-07'),
	(4, 13, '4024007120712467', '366', '2031-05-21'),
	(5, 14, '5388946431631667', '938', '2031-08-07'),
	(6, 15, '5339450679758878', '145', '2023-08-01'),
	(7, 16, '5113031906904634', '120', '2031-08-14');


--
-- Data for Name: Customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Customer" (user_id, name, surname, username, email, birthdate, country, state, city, phone, password, "postalCode", address) VALUES
	(1, 'ahmed', 'karoui', 'ahmedd22', 'ahhm@yahoo.fr', '1999-04-15', 'France', 'ile de france', 'paris', '+3387412015', 'ahmed1234', '54321', '07 rue des jammins'),
	(11, 'ahmed', 'karoui', 'ahmedd252', 'ahheem@yahoo.fr', '1999-04-15', 'France', 'ile de france', 'paris', '+3387412015', 'ahmed1234', '54321', '07 rue des jammins'),
	(12, 'loujey', 'zinedine', 'loulou79', 'loujeyedinn68@gmail.com', '1983-02-15', 'america', 'california', 'new york', '+242844554', '123456779loui', '5234', 'street of potato '),
	(13, 'lama', 'tejdin', 'lamou389', 'lamatjdin48@gmail.com', '1963-12-08', 'america', 'florida', 'miami', '+2152564764', 'ka3bamlewi', '3529', 'street of cringe '),
	(14, 'karim', 'hedi', 'agha2585', 'kimohedi50@gmail.com', '2001-01-08', 'Azerbaijan', 'baku', 'baku', '+213572564', 'zoro250kilo', '3209', 'street of go '),
	(15, 'sandy', 'aghayev', 'aghandy85', 'sandyaghayev0@gmail.com', '1975-11-28', 'Azerbaijan', 'baku', 'baku', '+9941556469', 'luffy5naruto', '5209', 'street of washington '),
	(16, 'fredi', 'sefi', 'fredis85', 'fredok90@gmail.com', '1985-12-26', 'america', 'florida', 'miami', '+3215564869', 'ka3bamlewi', '10089', 'city of flowers'),
	(17, 'salim', 'sta', 'salim24', 'salimsta60@gmail.com', '1989-02-24', 'america', 'california', 'san diego', '(555) 555-1234', 'sahfalablebi25', '10001', '132, My street');


--
-- Data for Name: Order; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Order" (order_id, customer_id, payment_id, total_price, "supplier_id ", "billingAddress", "shippingAddress", payment_date, placed_at) VALUES
	(17, 1, NULL, 15, 2, 1, 2, NULL, NULL),
	(19, 11, NULL, 15, 2, 2, 1, NULL, NULL),
	(21, 14, NULL, 15, 2, 4, 4, NULL, NULL),
	(23, 13, NULL, 15, 3, 3, 3, NULL, NULL),
	(24, 16, NULL, 15, 3, 6, 6, NULL, NULL),
	(14, 15, NULL, 10417, 7, 5, 5, NULL, NULL),
	(26, 16, NULL, 0, 2, 6, 6, NULL, '2020-12-27'),
	(13, 14, 4, 29, 2, 4, 4, '2020-12-27', NULL),
	(20, 13, NULL, 18, 3, 3, 3, NULL, NULL),
	(22, 15, NULL, 2470, 7, 5, 5, NULL, NULL),
	(15, 13, NULL, 1265, 3, 3, 3, NULL, NULL),
	(16, 16, NULL, 2435, 3, 6, 6, NULL, NULL),
	(9, 1, 1, 762, 2, 1, 2, NULL, NULL),
	(10, 1, 2, 415, 2, 1, 2, NULL, NULL),
	(11, 11, 3, 68526, 2, 2, 1, NULL, NULL),
	(12, 13, NULL, 318, 3, 3, 3, NULL, NULL),
	(18, 1, NULL, 15, 2, 1, 2, NULL, NULL);


--
-- Data for Name: OrderItem; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."OrderItem" (order_id, product_id, price, quantity, discount, size, color, shipped_at, delivered_at, shipping_id) VALUES
	(10, 2, 14.5, 1, 0, 14.5, 'purple', NULL, NULL, 1),
	(11, 2, 14.5, 1, 0, 14.5, 'red', NULL, NULL, 1),
	(14, 5, 14.5, 1, 0, 14.5, 'purple', NULL, NULL, 4),
	(17, 2, 14.5, 1, 0, 14.5, 'white', NULL, NULL, 2),
	(19, 2, 14.5, 1, 0, 14.5, 'black', NULL, NULL, 1),
	(21, 7, 14.5, 1, 0, 14.5, 'grey', NULL, NULL, 5),
	(23, 2, 14.5, 1, 0, 14.5, 'blue', NULL, NULL, 2),
	(24, 2, 14.5, 1, 0, 14.5, 'green', NULL, NULL, 1),
	(12, 4, 20, 1, 0, 14.5, 'purple', NULL, NULL, 3),
	(14, 4, 10402, 2, 20, 14.2, 'purple', NULL, NULL, 3),
	(16, 4, -9.578, 2, 20, 14.2, 'purple', NULL, NULL, 3),
	(9, 4, 510.600, 100, 25, 10.2, 'red', NULL, NULL, 1),
	(11, 7, 67526.50, 54, 15, 1.2, 'grey', '2020-12-27', '2020-12-27', 1),
	(13, 4, 29.133, 3, 1, 14.5, 'red', '2020-12-27', '2020-12-27', 3),
	(20, 4, 17.711, 1, 2, 14.5, 'black', '2020-12-29', '2020-12-29', 3),
	(22, 17, 2470.00, 1, 0, 14.5, 'pink', '2020-12-29', '2020-12-29', 6),
	(15, 7, 1265.00, 1, 0, 14.5, 'purple', '2020-12-29', '2020-12-29', 5),
	(10, 5, 372.5, 2, 10, 10.2, 'green', '2020-12-22', '2020-12-22', 1),
	(16, 17, 2445.00, 1, 25, 14.5, 'green', NULL, NULL, 6),
	(9, 2, 250, 100, 0, 10.2, 'red', NULL, NULL, 1),
	(9, 5, 1, 100, 1, 10.2, 'red', NULL, NULL, 1),
	(10, 15, 28, 104, 4, 12.2, 'blue', NULL, NULL, 1),
	(11, 6, 985, 170, 6, 104, 'red', NULL, NULL, 1),
	(12, 2, 298, 140, 3, 12.2, 'blue', NULL, NULL, 1),
	(18, 2, 14.5, 3, 2, 14.5, 'white', '2020-12-15', '2020-12-15', 1);


--
-- Data for Name: ParentCategory; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."ParentCategory" (name, description, nmbr_categories, category_id) VALUES
	('Woman', 'women articles', 4, 2),
	('Electronics', 'Electronic articles', 5, 5),
	('supermarket', 'supermarket articles', 6, 6),
	('shoes and bags', 'shoes and bags', 2, 7),
	('Sports', 'noth', 0, 10),
	('Men', 'articles for men', 2, 3),
	('Children', 'Children Products', 0, 8),
	('House and living', 'House and living articles', 4, 4);


--
-- Data for Name: Payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Payment" (payment_id, order_id, card_id, type_id, state, processed_at) VALUES
	(1, 9, 1, 1, 'processed', '2020-12-27'),
	(2, 10, 2, 1, 'processed', '2020-12-27'),
	(3, 11, 3, 1, 'processed', '2020-12-27'),
	(4, 13, 3, 1, 'processed', '2020-12-27');


--
-- Data for Name: PaymentMethod; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."PaymentMethod" (type_id, name, supplier_id) VALUES
	(1, 'CreditCard', 1),
	(2, 'Paypal', 2),
	(3, 'CreditCard', 3),
	(4, 'CreditCard', 7);


--
-- Data for Name: Product; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Product" (product_id, category_id, supplier_id, name, description, "UnitPrice", discount, "UnitsInStock", picture, ranking, "parentCategory") VALUES
	(15, 1, 1, 'huawei', NULL, 20.50, 0, 20, NULL, NULL, 4),
	(17, 1, 1, 'iphone', NULL, 2455.50, 0, 20, NULL, NULL, 4),
	(5, 2, 3, 'lenovo ideapad', '', 120, 11, 10, NULL, NULL, 5),
	(6, 2, 2, 'dell', '', 450.25, 11, 10, NULL, NULL, 6),
	(2, 1, 2, 'lenovo', '', 15, 5.50, 10, NULL, NULL, 2),
	(4, 1, 2, 'oppo', 'kikclsdnl', 5.211, 55, 10, NULL, NULL, 4),
	(7, 1, 2, 'acer', 'Acer''s new Smartphone', 1250.50, 20.1, 10, NULL, NULL, 7),
	(29, 5, 3, 'Zara Shirt', 'Zara''sT-shirt', 120.4, 5, 10, NULL, NULL, 2);


--
-- Data for Name: Shipper; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Shipper" (shipper_id, "CompanyName", phone) VALUES
	(1, 'DHL', '+21658741258'),
	(2, 'chinaPost', '+8741522145'),
	(3, 'SingapourExpress', '+8584152145');


--
-- Data for Name: ShippingAddress; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."ShippingAddress" (address_id, customer_id, "shipAddress", city, country_code, "postalCode") VALUES
	(1, 11, '07 rue des jammins', 'Paris', 'FRA', '54321'),
	(2, 1, '07 rue des jammins', 'Paris', 'FRA', '54321'),
	(3, 13, 'street of potato ', 'Chicago', 'USA', '98741'),
	(4, 14, 'street of cringe ', 'Washington', 'USA', '20145'),
	(5, 15, 'street of go ', 'Baku', 'AZE', '68541'),
	(6, 16, 'street of Washington ', 'Tunis', 'TUN', '7000 ');


--
-- Data for Name: ShippingOptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."ShippingOptions" (shipping_id, supplier_id, shipper_id, product_id, shipping_price, country_code) VALUES
	(1, 2, 1, 2, 14.5, 'USA'),
	(2, 2, 2, 2, 144.5, 'FRA'),
	(3, 2, 1, 4, 14.5, 'TUN'),
	(4, 3, 1, 5, 142.5, 'USA'),
	(5, 2, 2, 7, 14.5, 'AZE'),
	(6, 1, 1, 17, 14.5, 'FRA');


--
-- Data for Name: Supplier; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Supplier" (supplier_id, "CompanyName", "firstName", "lastName", address, city, country, "postalCode", phone, email) VALUES
	(2, 'Adidas', 'Ahmet', 'Said', 'Kemalpasa', 'Sakarya', 'Turkiye', '75000', '5512014541', 'ahmet551452@yahoo.com'),
	(1, 'Zara', 'Ayse', 'Bolu', 'Beyoglu', 'Istanbul', 'Turkiye', '', '', 'ayse1452@yahoo.com'),
	(7, 'Dell', 'zuleyha', 'alin', 'almaty', 'almaty', 'kazakhstan', '74820', '', 'zuleyha@gmail.com'),
	(3, 'Nike', 'Mehmet', 'beyoglu', 'yeni Camii 1', 'Sakarya', 'Turkiye', '54050', '+905417894214', 'ayse1452@yahoo.com');


--
-- Name: BillingAddress_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."BillingAddress_address_id_seq"', 6, true);


--
-- Name: BillingAddress_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."BillingAddress_customer_id_seq"', 1, false);


--
-- Name: CartItem_cart_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."CartItem_cart_id_seq"', 1, false);


--
-- Name: CartItem_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."CartItem_product_id_seq"', 1, false);


--
-- Name: CartItem_shipping_id _seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."CartItem_shipping_id _seq"', 1, false);


--
-- Name: Cart_cart_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Cart_cart_id_seq"', 1, false);


--
-- Name: Cart_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Cart_customer_id_seq"', 1, false);


--
-- Name: Category_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Category_category_id_seq"', 26, true);


--
-- Name: Category_name _seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Category_name _seq"', 1, false);


--
-- Name: Category_parentCategory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Category_parentCategory_id_seq"', 1, false);


--
-- Name: CreditCard_card_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."CreditCard_card_id_seq"', 7, true);


--
-- Name: CreditCard_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."CreditCard_customer_id_seq"', 1, false);


--
-- Name: Customer_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Customer_user_id_seq"', 17, true);


--
-- Name: OrderItem_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."OrderItem_order_id_seq"', 1, false);


--
-- Name: OrderItem_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."OrderItem_product_id_seq"', 1, false);


--
-- Name: OrderItem_shipping_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."OrderItem_shipping_id_seq"', 1, false);


--
-- Name: Order_billingAddress_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Order_billingAddress_seq"', 1, false);


--
-- Name: Order_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Order_customer_id_seq"', 1, false);


--
-- Name: Order_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Order_order_id_seq"', 26, true);


--
-- Name: Order_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Order_payment_id_seq"', 1, false);


--
-- Name: Order_shippingAddress_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Order_shippingAddress_seq"', 1, false);


--
-- Name: Order_supplier_id _seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Order_supplier_id _seq"', 1, false);


--
-- Name: ParentCategory_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ParentCategory_category_id_seq"', 11, true);


--
-- Name: PaymentMethod_supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."PaymentMethod_supplier_id_seq"', 1, false);


--
-- Name: PaymentMethod_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."PaymentMethod_type_id_seq"', 4, true);


--
-- Name: Payment_card_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Payment_card_id_seq"', 1, false);


--
-- Name: Payment_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Payment_order_id_seq"', 1, false);


--
-- Name: Payment_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Payment_payment_id_seq"', 4, true);


--
-- Name: Payment_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Payment_type_id_seq"', 1, false);


--
-- Name: Product_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Product_category_id_seq"', 1, false);


--
-- Name: Product_parentCategory_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Product_parentCategory_seq"', 25, true);


--
-- Name: Product_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Product_product_id_seq"', 31, true);


--
-- Name: Product_supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Product_supplier_id_seq"', 1, false);


--
-- Name: Shipper_shipper_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Shipper_shipper_id_seq"', 3, true);


--
-- Name: ShippingAddress_address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ShippingAddress_address_id_seq"', 6, true);


--
-- Name: ShippingAddress_customer_id _seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ShippingAddress_customer_id _seq"', 1, false);


--
-- Name: ShippingOptions_product_id _seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ShippingOptions_product_id _seq"', 1, false);


--
-- Name: ShippingOptions_shipper_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ShippingOptions_shipper_id_seq"', 1, false);


--
-- Name: ShippingOptions_shipping_id _seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ShippingOptions_shipping_id _seq"', 6, true);


--
-- Name: ShippingOptions_supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ShippingOptions_supplier_id_seq"', 1, false);


--
-- Name: Supplier_supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Supplier_supplier_id_seq"', 10, true);


--
-- Name: BillingAddress BillingAddress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BillingAddress"
    ADD CONSTRAINT "BillingAddress_pkey" PRIMARY KEY (address_id, customer_id);


--
-- Name: CartItem CartItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartItem"
    ADD CONSTRAINT "CartItem_pkey" PRIMARY KEY (cart_id, product_id);


--
-- Name: Cart Cart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cart"
    ADD CONSTRAINT "Cart_pkey" PRIMARY KEY (cart_id, customer_id);


--
-- Name: Category Category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Category"
    ADD CONSTRAINT "Category_pkey" PRIMARY KEY (category_id);


--
-- Name: Country Country _pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Country"
    ADD CONSTRAINT "Country _pkey" PRIMARY KEY (country_code);


--
-- Name: CreditCard CreditCard_card_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCard"
    ADD CONSTRAINT "CreditCard_card_id_key" UNIQUE (card_id);


--
-- Name: CreditCard CreditCard_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCard"
    ADD CONSTRAINT "CreditCard_pkey" PRIMARY KEY (card_id, customer_id);


--
-- Name: OrderItem OrderItem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItem"
    ADD CONSTRAINT "OrderItem_pkey" PRIMARY KEY (order_id, product_id);


--
-- Name: Order Order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "Order_pkey" PRIMARY KEY (order_id);


--
-- Name: ParentCategory ParentCategory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ParentCategory"
    ADD CONSTRAINT "ParentCategory_pkey" PRIMARY KEY (category_id);


--
-- Name: PaymentMethod PaymentMethod_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PaymentMethod"
    ADD CONSTRAINT "PaymentMethod_pkey" PRIMARY KEY (type_id);


--
-- Name: Payment Payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "Payment_pkey" PRIMARY KEY (payment_id, order_id, type_id);


--
-- Name: Product Product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product"
    ADD CONSTRAINT "Product_pkey" PRIMARY KEY (product_id);


--
-- Name: Shipper Shipper_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Shipper"
    ADD CONSTRAINT "Shipper_pkey" PRIMARY KEY (shipper_id);


--
-- Name: ShippingAddress ShippingAddress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingAddress"
    ADD CONSTRAINT "ShippingAddress_pkey" PRIMARY KEY (address_id, customer_id);


--
-- Name: ShippingOptions ShippingOptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingOptions"
    ADD CONSTRAINT "ShippingOptions_pkey" PRIMARY KEY (shipping_id, supplier_id, shipper_id, country_code);


--
-- Name: Supplier Supplier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Supplier"
    ADD CONSTRAINT "Supplier_pkey" PRIMARY KEY (supplier_id);


--
-- Name: BillingAddress unique_BillingAddress_address_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BillingAddress"
    ADD CONSTRAINT "unique_BillingAddress_address_id" UNIQUE (address_id);


--
-- Name: Cart unique_Cart_cart_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cart"
    ADD CONSTRAINT "unique_Cart_cart_id" UNIQUE (cart_id);


--
-- Name: Customer unique_Customer_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customer"
    ADD CONSTRAINT "unique_Customer_email" UNIQUE (email);


--
-- Name: Customer unique_Customer_user_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customer"
    ADD CONSTRAINT "unique_Customer_user_id" PRIMARY KEY (user_id);


--
-- Name: Customer unique_Customer_username; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customer"
    ADD CONSTRAINT "unique_Customer_username" UNIQUE (username);


--
-- Name: ShippingAddress unique_ShippingAddress_address_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingAddress"
    ADD CONSTRAINT "unique_ShippingAddress_address_id" UNIQUE (address_id);


--
-- Name: index_address_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_address_id ON public."BillingAddress" USING btree (address_id);


--
-- Name: Category triggerCat; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "triggerCat" BEFORE INSERT ON public."Category" FOR EACH ROW EXECUTE PROCEDURE public."setToZero"();


--
-- Name: OrderItem triggerOrder; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "triggerOrder" AFTER INSERT OR DELETE OR UPDATE ON public."OrderItem" FOR EACH ROW EXECUTE PROCEDURE public."calculateOrderPrice"();


--
-- Name: ParentCategory triggerParent; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "triggerParent" BEFORE INSERT ON public."ParentCategory" FOR EACH ROW EXECUTE PROCEDURE public."setChildCatsToZero"();


--
-- Name: Payment triggerPayment; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "triggerPayment" AFTER INSERT ON public."Payment" FOR EACH ROW EXECUTE PROCEDURE public."setPayment"();


--
-- Name: Order triggerPlacementDate; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "triggerPlacementDate" BEFORE INSERT ON public."Order" FOR EACH ROW EXECUTE PROCEDURE public."setDate"();


--
-- Name: Payment triggerPlacementDate; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "triggerPlacementDate" BEFORE INSERT ON public."Payment" FOR EACH ROW EXECUTE PROCEDURE public."setDatePayment"();


--
-- Name: OrderItem triggerPriceCalculate; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "triggerPriceCalculate" AFTER INSERT OR UPDATE ON public."OrderItem" FOR EACH ROW EXECUTE PROCEDURE public."calculatePriceItem"();


--
-- Name: Product triggerProd; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "triggerProd" BEFORE INSERT ON public."Product" FOR EACH ROW EXECUTE PROCEDURE public."setParentCategory"();


--
-- Name: Cart CustFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cart"
    ADD CONSTRAINT "CustFK" FOREIGN KEY (customer_id) REFERENCES public."Customer"(user_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Order billAddressFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "billAddressFK" FOREIGN KEY ("billingAddress") REFERENCES public."BillingAddress"(address_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Payment cardFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "cardFK" FOREIGN KEY (card_id) REFERENCES public."CreditCard"(card_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CartItem cartFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartItem"
    ADD CONSTRAINT "cartFK" FOREIGN KEY (cart_id) REFERENCES public."Cart"(cart_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Product categoryFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product"
    ADD CONSTRAINT "categoryFK" FOREIGN KEY (category_id) REFERENCES public."Category"(category_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ShippingOptions cntryFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingOptions"
    ADD CONSTRAINT "cntryFK" FOREIGN KEY (country_code) REFERENCES public."Country"(country_code) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Country countryFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Country"
    ADD CONSTRAINT "countryFK" FOREIGN KEY (country_code) REFERENCES public."Country"(country_code) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BillingAddress country_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BillingAddress"
    ADD CONSTRAINT country_fk FOREIGN KEY (country_code) REFERENCES public."Country"(country_code) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CreditCard custFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CreditCard"
    ADD CONSTRAINT "custFK" FOREIGN KEY (customer_id) REFERENCES public."Customer"(user_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ShippingAddress customerFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingAddress"
    ADD CONSTRAINT "customerFK" FOREIGN KEY (customer_id) REFERENCES public."Customer"(user_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Order customerProdFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "customerProdFK" FOREIGN KEY (customer_id) REFERENCES public."Customer"(user_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: BillingAddress customer_idFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BillingAddress"
    ADD CONSTRAINT "customer_idFK" FOREIGN KEY (customer_id) REFERENCES public."Customer"(user_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrderItem orderFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItem"
    ADD CONSTRAINT "orderFK" FOREIGN KEY (order_id) REFERENCES public."Order"(order_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Payment orderPaymentFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "orderPaymentFK" FOREIGN KEY (order_id) REFERENCES public."Order"(order_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Order orderSupplierFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "orderSupplierFK" FOREIGN KEY ("supplier_id ") REFERENCES public."Supplier"(supplier_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Category parentCatFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Category"
    ADD CONSTRAINT "parentCatFK" FOREIGN KEY ("parentCategory_id") REFERENCES public."ParentCategory"(category_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Product parentCatFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product"
    ADD CONSTRAINT "parentCatFK" FOREIGN KEY ("parentCategory") REFERENCES public."ParentCategory"(category_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Payment paymentTypeFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "paymentTypeFK" FOREIGN KEY (type_id) REFERENCES public."PaymentMethod"(type_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ShippingOptions prdFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingOptions"
    ADD CONSTRAINT "prdFK" FOREIGN KEY (product_id) REFERENCES public."Product"(product_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CartItem productCartFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartItem"
    ADD CONSTRAINT "productCartFK" FOREIGN KEY (product_id) REFERENCES public."Product"(product_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrderItem productOrderFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderItem"
    ADD CONSTRAINT "productOrderFK" FOREIGN KEY (product_id) REFERENCES public."Product"(product_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Order shipAddress; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "shipAddress" FOREIGN KEY ("shippingAddress") REFERENCES public."ShippingAddress"(address_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ShippingOptions shipperFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingOptions"
    ADD CONSTRAINT "shipperFK" FOREIGN KEY (shipper_id) REFERENCES public."Shipper"(shipper_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ShippingOptions suppFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ShippingOptions"
    ADD CONSTRAINT "suppFK" FOREIGN KEY (supplier_id) REFERENCES public."Supplier"(supplier_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: PaymentMethod supplierFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."PaymentMethod"
    ADD CONSTRAINT "supplierFK" FOREIGN KEY (supplier_id) REFERENCES public."Supplier"(supplier_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Product supplierFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product"
    ADD CONSTRAINT "supplierFK" FOREIGN KEY (supplier_id) REFERENCES public."Supplier"(supplier_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Order supplierFK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "supplierFK" FOREIGN KEY ("supplier_id ") REFERENCES public."Supplier"(supplier_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

