using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Npgsql; 

namespace VeriTabani
{
    public partial class OrderManagementSystem : Form
    {
        private string supplId = "";
        private string prodId = "";
        private string parentCatId = "";
        private string CategoryId = "";
        private string OrderId = "";
        private string OrderItemId = "";
        private string customerId = "";
        public OrderManagementSystem()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            loadData();
        }
        private void fillInProducts()
        {
            Crud.sql = "SELECT \"product_id\", p.\"name\", c.\"name\" as \"category\",\"supplier_id\",p.\"description\", \"UnitPrice\" as \"Unit Price\", \"discount\", \"UnitsInStock\" as \"Units In Stock\", pc.\"name\" as \"Parent Category\" , p.\"ranking\"" +
            " FROM public.\"Product\" p LEFT JOIN public.\"Category\" c ON c.category_id = p.category_id LEFT JOIN public.\"ParentCategory\" as pc ON pc.\"category_id\" = p.\"parentCategory\" ;";
            Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            DataTable dt = Crud.PerformCRUD(Crud.cmd);
            DataGridView dgv1 = productGridView;
            dgv1.MultiSelect = false;
            dgv1.AutoGenerateColumns = true;
            dgv1.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgv1.DataSource = dt;

        }
        private void fillInParentCategories()
        {
            Crud.sql = "SELECT * FROM \"public\".\"ParentCategory\" ";
            Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            DataTable dt = Crud.PerformCRUD(Crud.cmd);
            DataGridView dgv1 = parentCatGridView;
            dgv1.MultiSelect = false;
            dgv1.AutoGenerateColumns = true;
            dgv1.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgv1.DataSource = dt;
            dgv1.Columns[2].HeaderText = "number of sub-categories";
        }
        private void fillInCustomer(string param)
        {
            if (param == "")
            {
                Crud.sql = "SELECT * FROM \"public\".\"Customer\" ; ";
                Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            }
            else
            {
                Crud.sql = "SELECT * FROM \"public\".\"Customer\" WHERE \"name\"LIKE @Name ";
                Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
                Crud.cmd.Parameters.AddWithValue("Name", param);
            }
            DataTable dt = Crud.PerformCRUD(Crud.cmd);
            DataGridView dgv1 = CustomerGridView;
            dgv1.MultiSelect = false;
            dgv1.AutoGenerateColumns = true;
            dgv1.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgv1.DataSource = dt;
        }

        //Search result 
        private void Search_Click(object sender, EventArgs e)
        {
            string name = Convert.ToString(SearchBox.Text.Trim()) + "%";
            fillInCustomer(name);
        }


        private void fillInOrders()
        {
            Crud.sql = " SELECT o.\"order_id\",o.\"customer_id\",o.\"payment_id\",o.\"total_price\" as \"Total Price\", "+ 
	" ba.\"billingAddress\" AS \"Billing Adress\",sa.\"shipAddress\" AS \"Billing Adress\" ,o.\"payment_date\",o.\"placed_at\" "+
    " FROM \"public\".\"Order\" o LEFT JOIN  \"public\".\"BillingAddress\" ba ON ba.\"address_id\" = o.\"billingAddress\" RIGHT JOIN " +
    " \"public\".\"ShippingAddress\" sa ON sa.\"address_id\" = o.\"shippingAddress\"; ";
            Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            DataTable dt = Crud.PerformCRUD(Crud.cmd);
            DataGridView dgv1 = OrderGridView;
            dgv1.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgv1.DataSource = dt;
        }
        private void fillInCategories()
        {
            Crud.sql = "SELECT c.\"category_id\",pc.\"name\" as \"Parent Category\",c.\"name\",\"nmbr_products\" "+
            " FROM \"public\".\"Category\" c LEFT JOIN \"public\".\"ParentCategory\" pc ON" +
            " \"parentCategory_id\" = pc.\"category_id\"; ";
            Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            DataTable dt = Crud.PerformCRUD(Crud.cmd);
            DataGridView dgv1 = catGridView;
            dgv1.MultiSelect = false;
            dgv1.AutoGenerateColumns = true;
            dgv1.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgv1.DataSource = dt;
            dgv1.Columns[1].HeaderText = "Parent Category id";
            dgv1.Columns[3].HeaderText = "Number of Products";
        }
        private void fillInSuppliers()
        {
            Crud.sql = "SELECT * FROM \"public\".\"Supplier\" ";
            Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            DataTable dt = Crud.PerformCRUD(Crud.cmd);
            DataGridView dgv1 = SupplierGridView;
            dgv1.MultiSelect = false;
            dgv1.AutoGenerateColumns = true;
            dgv1.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgv1.DataSource = dt;
            dgv1.Columns[1].HeaderText = "Company Name";
            dgv1.Columns[2].HeaderText = "First Name";
            dgv1.Columns[3].HeaderText = "Last Name";
            dgv1.Columns[7].HeaderText = "Postal Code";
        }
        private void fillDropDown()
        {
            Crud.sql = "SELECT \"name\" FROM \"public\".\"ParentCategory\" ";
            Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            DataTable dt = Crud.PerformCRUD(Crud.cmd);
            ParentCatDropDown.DataSource = dt;
            ParentCatDropDown.DisplayMember = "name";
            Crud.sql = "SELECT * FROM \"public\".\"Category\" ";
            Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            DataTable dt1 = Crud.PerformCRUD(Crud.cmd);
            categoryDropDown.DataSource = dt1;
            categoryDropDown.DisplayMember = "name";
            Crud.sql = "SELECT * FROM \"public\".\"Supplier\" ";
            Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            DataTable dt2 = Crud.PerformCRUD(Crud.cmd);
            SupplierDropDown.DataSource = dt2;
            SupplierDropDown.DisplayMember = "supplier_id";
            /*Crud.cmd.Parameters.Clear();*/
        }

        private void fillInOrderItems()
        {
            Crud.sql = "SELECT * FROM (SELECT p.\"name\" AS \"Name\", o.* FROM \"public\".\"OrderItem\" o LEFT JOIN \"public\".\"Product\" p " +
            "ON p.\"product_id\" = o.\"product_id\") AS tb WHERE \"order_id\"= @OrderId::int ";
            Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            Crud.cmd.Parameters.AddWithValue("OrderId", this.OrderId);
            DataTable dt2 = Crud.PerformCRUD(Crud.cmd);
            DataGridView dgv2 = OrderItemsGridView;
            dgv2.MultiSelect = false;
            dgv2.AutoGenerateColumns = true;
            dgv2.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            dgv2.DataSource = dt2;
        }

        private void loadData()
        {
            fillInCategories();
            fillInParentCategories();
            fillInProducts();
            fillDropDown();
            fillInSuppliers();
            fillInOrders();
            fillInCustomer("");
        }
        private void execute(string mySQL, string param, string table )
        {
            Crud.cmd = new NpgsqlCommand(mySQL, Crud.con);
            addParameters(param,table);
            Crud.PerformCRUD(Crud.cmd);
        }
        private void addParameters(string str, string table)
        {
            Crud.cmd.Parameters.Clear();
            if (table == "supplier")
            {
                paramSupplier();
            }else if (table == "product")
            {
                string temp = Crud.sql;
                paramProduct(temp);
            }else if (table == "parentCat")
            {
                paramParentCat();
            }else if (table == "category")
            {
                string temp = Crud.sql;
                paramCat(temp);
            }
            else if (table == "OrderItem")
            {
                paramOrder();
            }

            if (str == "Update" || str == "Delete" )
            {
                if (table == "supplier" && !string.IsNullOrEmpty(this.supplId))
                {
                    Crud.cmd.Parameters.AddWithValue("id", this.supplId);
                }else if (table == "OrderItem" && !string.IsNullOrEmpty(this.OrderItemId))
                {
                    Crud.cmd.Parameters.AddWithValue("itemId", this.OrderItemId);
                    Crud.cmd.Parameters.AddWithValue("id", this.prodId);
                }
                else if (table == "product" && !string.IsNullOrEmpty(this.prodId)) 
                {
                    Crud.cmd.Parameters.AddWithValue("id", this.prodId);
                }else if (table == "parentCat" && !string.IsNullOrEmpty(this.parentCatId))
                {
                    Crud.cmd.Parameters.AddWithValue("id", this.parentCatId);
                }else if (table == "category" && !string.IsNullOrEmpty(this.CategoryId))
                {
                    Crud.cmd.Parameters.AddWithValue("id", this.CategoryId);
                }

            }
        }
        //Update order Item 
        private void btnOrder_Click(object sender, EventArgs e)
        {

            if(OrderItemsGridView.Rows.Count == 0)
            {
                return;
            }
            if (String.IsNullOrEmpty(this.OrderItemId))
            {
                MessageBox.Show("Please select an item from the list ", "Update order item", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Crud.sql = "UPDATE \"public\".\"OrderItem\" SET \"quantity\" = @quantity::int,\"discount\" = @discount::numeric, " +
            " \"shipped_at\" = @shippingDate::DATE,\"delivered_at\" = @deliveryDate::date WHERE order_id=@itemId::int AND \"product_id\" = @id::int ;";
            execute(Crud.sql, "Update", "OrderItem");
            MessageBox.Show("The record has been updated ", "Update order item", MessageBoxButtons.OK, MessageBoxIcon.Information);
            this.OrderItemId = "";
            this.prodId = "";
            loadData();
            fillInOrderItems();
        }





        //add product
        private void insertbtn_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(PName.Text.Trim()) ||
                string.IsNullOrEmpty(UnitPrice.Text.Trim()) ||
                string.IsNullOrEmpty(unitsInStock.Text.Trim()))
            {
                MessageBox.Show("Please input product name unit price and units in stock ", "Insert product", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Crud.sql = "INSERT INTO \"public\".\"Product\" ( \"category_id\", \"supplier_id\", \"name\", " +
               " \"description\", \"UnitPrice\", \"discount\", \"UnitsInStock\") " +
               " VALUES( @category_id::int, @supplier_id::int, @name, @description, @UnitPrice::numeric, @discount::numeric, @UnitsInStock::int );";
            execute(Crud.sql, "Insert", "product");
            MessageBox.Show("The record has been inserted ", "Insert Product", MessageBoxButtons.OK, MessageBoxIcon.Information);
            loadData();

        }

        //add a category 
        private void insertCatbtn_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(catName.Text.Trim()) ||
                string.IsNullOrEmpty(nmbrProd.Text.Trim()))
            {
                MessageBox.Show("Please input category name and number of products ", "Insert category", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Crud.sql = "INSERT INTO \"public\".\"Category\" ( \"parentCategory_id\", \"name\", \"nmbr_products\") " + 
                " VALUES( @parentCategory_id::int , @name , @nmbr_products::int  );";
            execute(Crud.sql, "Insert", "category");
            MessageBox.Show("The record has been inserted ", "Insert category", MessageBoxButtons.OK, MessageBoxIcon.Information);
            loadData();
        }



        //add a supplier
        private void insertSupplierbtn_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(fNameFieldSuppl.Text.Trim()) || 
                string.IsNullOrEmpty(lNameFieldSuppl.Text.Trim()) ||
                string.IsNullOrEmpty(emailFieldSuppl.Text.Trim()))
            {
                MessageBox.Show("Please input first name last name and email ", "Insert supplier", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Crud.sql = "INSERT INTO \"public\".\"Supplier\"( \"CompanyName\", \"firstName\", \"lastName\", \"address\"," +
                " \"city\", \"country\", \"postalCode\", \"phone\", \"email\") " +
                " VALUES( @CompanyName, @firstName, @lastName, @address," +
                " @city , @country , @postalCode , @phone , @email );"; 
            execute(Crud.sql, "Insert", "supplier");
            MessageBox.Show("The record has been inserted ", "Insert Supplier", MessageBoxButtons.OK, MessageBoxIcon.Information);
            loadData();

        }
        //select order item 
        private void OrderItemsGridView_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex != -1)
            {
                UpdateOrder.Visible = labelDiscount.Visible = labelQuantity.Visible = btnOrder.Visible = 
                quantity.Visible = labeldate2.Visible = labeldate1.Visible = disc.Visible =   true;
                DataGridView dgv1 = OrderItemsGridView;
                this.OrderItemId = Convert.ToString(dgv1.CurrentRow.Cells[1].Value);
                this.prodId = Convert.ToString(dgv1.CurrentRow.Cells[2].Value);
                quantity.Text = Convert.ToString(dgv1.CurrentRow.Cells[4].Value);
                disc.Text = Convert.ToString(dgv1.CurrentRow.Cells[5].Value);
                dateTimePickerShip.Value =
                    Convert.ToString(dgv1.CurrentRow.Cells[8].Value) != ""?
                    Convert.ToDateTime(dgv1.CurrentRow.Cells[8].Value):
                    DateTime.Today;
                dateTimePickerDelivery.Value =
                Convert.ToString(dgv1.CurrentRow.Cells[9].Value) != "" ?
                Convert.ToDateTime(dgv1.CurrentRow.Cells[9].Value):
                DateTime.Today; 
            }
        }        
        
        // Select a customer
        private void CustomerGridView_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex != -1)
            {
                DataGridView dgv1 = CustomerGridView;
                this.customerId = Convert.ToString(dgv1.CurrentRow.Cells[0].Value);
                OrderGridView2.Visible = labelOrderList.Visible = true;
                Crud.sql = "SELECT * FROM (SELECT o.\"order_id\",o.\"customer_id\" as \"customer_id\",o.\"payment_id\",o.\"total_price\" as \"Total Price\", " +
    " ba.\"billingAddress\" AS \"Billing Adress\",sa.\"shipAddress\" AS \"Shipping Adress\" ,o.\"payment_date\",o.\"placed_at\" " +
    " FROM \"public\".\"Order\" o LEFT JOIN  \"public\".\"BillingAddress\" ba ON ba.\"address_id\" = o.\"billingAddress\" RIGHT JOIN " +
    " \"public\".\"ShippingAddress\" sa ON sa.\"address_id\" = o.\"shippingAddress\")AS tb WHERE \"customer_id\"=@customerId::int ;";
                Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
                Crud.cmd.Parameters.AddWithValue("customerId", this.customerId);
                DataTable dt2 = Crud.PerformCRUD(Crud.cmd);
                DataGridView dgv2 = OrderGridView2;
                dgv2.MultiSelect = false;
                dgv2.AutoGenerateColumns = true;
                dgv2.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
                dgv2.DataSource = dt2;
            }
        }

        //select an order
        private void OrderGridView_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex != -1)
            {
                DataGridView dgv1 = OrderGridView;
                this.OrderId = Convert.ToString(dgv1.CurrentRow.Cells[0].Value);
                orderItems.Visible = true;
                OrderItemsGridView.Visible = true;
                Crud.sql = "SELECT * FROM (SELECT p.\"name\" AS \"Name\", o.* FROM \"public\".\"OrderItem\" o LEFT JOIN \"public\".\"Product\" p "+
                "ON p.\"product_id\" = o.\"product_id\") AS tb WHERE \"order_id\"= @OrderId::int ";
                Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
                Crud.cmd.Parameters.AddWithValue("OrderId", this.OrderId);
                DataTable dt2 = Crud.PerformCRUD(Crud.cmd);
                DataGridView dgv2 = OrderItemsGridView;
                dgv2.MultiSelect = false;
                dgv2.AutoGenerateColumns = true;
                dgv2.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
                dgv2.DataSource = dt2;
            }
        }
        //select a supplier 
        private void SupplierGridView_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if(e.RowIndex != -1)
            {
                DataGridView dgv1 = SupplierGridView;
                this.supplId = Convert.ToString(dgv1.CurrentRow.Cells[0].Value);
                updateSupplbtn.Text = "Update (" + this.supplId + ") ";
                deleteSupplbtn.Text = "Delete (" + this.supplId + ") ";
                
                companyNameSuppl.Text = Convert.ToString(dgv1.CurrentRow.Cells[1].Value);
                fNameFieldSuppl.Text = Convert.ToString(dgv1.CurrentRow.Cells[2].Value) ;
                lNameFieldSuppl.Text = Convert.ToString(dgv1.CurrentRow.Cells[3].Value);
                addrFieldSuppl.Text= Convert.ToString(dgv1.CurrentRow.Cells[4].Value);   
                cityFieldSuppl.Text =Convert.ToString(dgv1.CurrentRow.Cells[5].Value);  
                countryFieldSuppl.Text = Convert.ToString(dgv1.CurrentRow.Cells[6].Value);  
                pCodeFieldSuppl.Text = Convert.ToString(dgv1.CurrentRow.Cells[7].Value);
                phoneFieldSuppl.Text= Convert.ToString(dgv1.CurrentRow.Cells[8].Value);
                emailFieldSuppl.Text = Convert.ToString(dgv1.CurrentRow.Cells[9].Value);

            }
        }
        //select a product
        private void productGridView_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            DataGridView dgv1 = productGridView;
            this.prodId = Convert.ToString(dgv1.CurrentRow.Cells[0].Value); 
            PName.Text = Convert.ToString(dgv1.CurrentRow.Cells[1].Value);
            categoryDropDown.Text = Convert.ToString(dgv1.CurrentRow.Cells[2].Value);            
            SupplierDropDown.Text = Convert.ToString(dgv1.CurrentRow.Cells[3].Value);
            description.Text = Convert.ToString(dgv1.CurrentRow.Cells[4].Value);
            UnitPrice.Text = Convert.ToString(dgv1.CurrentRow.Cells[5].Value);
            discount.Text = Convert.ToString(dgv1.CurrentRow.Cells[6].Value);
            unitsInStock.Text = Convert.ToString(dgv1.CurrentRow.Cells[7].Value);
        }
        // select a parent category
        private void parentCatGridView_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            DataGridView dgv1 = parentCatGridView;
            this.parentCatId = Convert.ToString(dgv1.CurrentRow.Cells[3].Value);
            parentCatName.Text = Convert.ToString(dgv1.CurrentRow.Cells[0].Value);
            parentCatDesciption.Text = Convert.ToString(dgv1.CurrentRow.Cells[1].Value);
            subCatNmbr.Text = Convert.ToString(dgv1.CurrentRow.Cells[2].Value); 
        }

        //select a category
        private void catGridView_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            DataGridView dgv1 = catGridView;
            this.CategoryId = Convert.ToString(dgv1.CurrentRow.Cells[0].Value);
            ParentCatDropDown.Text = Convert.ToString(dgv1.CurrentRow.Cells[1].Value);
            catName.Text = Convert.ToString(dgv1.CurrentRow.Cells[2].Value);
            nmbrProd.Text = Convert.ToString(dgv1.CurrentRow.Cells[3].Value);
        }
        //update a supplier
        private void updateSupplbtn_Click(object sender, EventArgs e)
        {
            if(SupplierGridView.Rows.Count == 0)
            {
                return;
            }
            if (String.IsNullOrEmpty(this.supplId))
            {
                MessageBox.Show("Please select a supplier from the list ", "Update supplier", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Crud.sql = 
                "UPDATE \"public\".\"Supplier\" SET "+
	            "\"CompanyName\" = @CompanyName,"+
	              "\"firstName\" = @firstName,"+
	               "\"lastName\" = @lastName,"+
	                "\"address\" = @address,"+
	                   "\"city\" = @city,"+
	                "\"country\" = @country,"+
	             "\"postalCode\" = @postalCode,"+
	                  "\"phone\" = @phone,"+
                      "\"email\" = @email WHERE \"supplier_id\" = @id::int;";
            execute(Crud.sql, "Update", "supplier");
            MessageBox.Show("The record has been updated ", "Update Supplier", MessageBoxButtons.OK, MessageBoxIcon.Information);
            this.supplId = "";
            loadData();


        }

        //update a parent cat 
        private void updateParentCat_Click(object sender, EventArgs e)
        {
            if (parentCatGridView.Rows.Count == 0)
            {
                return;
            }
            if (String.IsNullOrEmpty(this.parentCatId))
            {
                MessageBox.Show("Please select a category from the list ", "Update parent category", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Crud.sql = "UPDATE \"public\".\"ParentCategory\" SET " +
	        " \"name\" = @name, "+
	        " \"description\" = @description, " +
	        " \"nmbr_categories\" = @nmbr_categories::int  " +
            " WHERE \"category_id\" = @id::int ;" ;
            execute(Crud.sql, "Update", "parentCat");
            MessageBox.Show("The record has been updated ", "Update Parent Category", MessageBoxButtons.OK, MessageBoxIcon.Information);
            this.parentCatId = "";
            loadData();
        }


        //delete a supplier
        private void deleteSupplbtn_Click(object sender, EventArgs e)
        {
            if (SupplierGridView.Rows.Count == 0)
            {
                return;
            }
            if (String.IsNullOrEmpty(this.supplId))
            {
                MessageBox.Show("Please select a supplier from the list ", "Update supplier", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Crud.sql =
                "DELETE FROM \"public\".\"Supplier\" WHERE \"supplier_id\" = @id::int;";
            execute(Crud.sql, "Delete", "supplier");
            MessageBox.Show("The record has been deleted ", "Delete Supplier", MessageBoxButtons.OK, MessageBoxIcon.Information);

            loadData();

        }

        //update a category 
        private void updateCatbtn_Click(object sender, EventArgs e)
        {
            if (catGridView.Rows.Count == 0)
            {
                return;
            }
            if (String.IsNullOrEmpty(this.CategoryId))
            {
                MessageBox.Show("Please select a category from the list ", "Update category", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Crud.sql = "UPDATE \"public\".\"Category\" SET \"parentCategory_id\" = @parentCategory_id::int, " +
	           "  \"name\" = @name, \"nmbr_products\" = @nmbr_products::int WHERE \"category_id\" = @id::int ;";
            execute(Crud.sql, "Update", "category");
            MessageBox.Show("The record has been updated ", "Update category", MessageBoxButtons.OK, MessageBoxIcon.Information);
            CategoryId = "";
            loadData();
        }

        //delete a category 
        private void deleteCatbtn_Click(object sender, EventArgs e)
        {
            if (catGridView.Rows.Count == 0)
            {
                return;
            }
            if (String.IsNullOrEmpty(this.CategoryId))
            {
                MessageBox.Show("Please select a category from the list ", "Delete category", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Crud.sql = "DELETE FROM\"public\".\"Category\" WHERE\"category_id\" = @id::int;";
            execute(Crud.sql, "Delete", "category");
            MessageBox.Show("The record has been deleted ", "delete category", MessageBoxButtons.OK, MessageBoxIcon.Information);
            CategoryId = "";
            loadData();

        }


        //update product
        private void updateProdbtn_Click(object sender, EventArgs e)
        {
            if (productGridView.Rows.Count == 0)
            {
                return;
            }
            if (String.IsNullOrEmpty(this.prodId))
            {
                MessageBox.Show("Please select a product from the list ", "Update product", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Crud.sql =
            "UPDATE \"public\".\"Product\" SET " +
            "\"name\" = @name," +
              "\"description\" = @description," +
               "\"UnitPrice\" = @UnitPrice::numeric," +
                "\"discount\" = @discount::numeric," +
                   "\"UnitsInStock\" = @UnitsInStock::int," +
                "\"category_id\" = @category_id::int," +
             "\"supplier_id\" = @supplier_id::int " +
                " WHERE \"product_id\" = @id::int;";
            execute(Crud.sql, "Update", "product");
            MessageBox.Show("The record has been updated ", "Update Product", MessageBoxButtons.OK, MessageBoxIcon.Information);
            prodId = "";
            loadData();
        }
        //delete product
        private void deleteProductbtn_Click(object sender, EventArgs e)
        {
            if (productGridView.Rows.Count == 0)
            {
                return;
            }
            if (String.IsNullOrEmpty(this.prodId))
            {
                MessageBox.Show("Please select a product from the list ", "Delete product", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Crud.sql =
               "DELETE FROM \"public\".\"Product\" WHERE \"product_id\" = @id::int;";
            execute(Crud.sql, "Delete", "product");
            MessageBox.Show("The record has been deleted ", "Delete Product", MessageBoxButtons.OK, MessageBoxIcon.Information);
            prodId = "";
            loadData();
        }


        //add parent category
        private void addParentCatbtn_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(parentCatName.Text.Trim()) || string.IsNullOrEmpty(subCatNmbr.Text.Trim()))
            {
                MessageBox.Show("Please input category name ", "Insert parent category", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Crud.sql = "INSERT INTO \"public\".\"ParentCategory\"( \"name\", \"description\", \"nmbr_categories\")" +
            " VALUES( @name , @description , @nmbr_categories::int );";
            execute(Crud.sql, "Insert", "parentCat");
            MessageBox.Show("The record has been inserted ", "Insert parent category", MessageBoxButtons.OK, MessageBoxIcon.Information);
            loadData();

        }

        //delete parent category
        private void deleteParentCatbtn_Click(object sender, EventArgs e)
        {
            if (parentCatGridView.Rows.Count == 0)
            {
                return;
            }
            if (String.IsNullOrEmpty(this.parentCatId))
            {
                MessageBox.Show("Please select a category from the list ", "Delete parent category ", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }
            Crud.sql =
               "DELETE FROM \"public\".\"ParentCategory\" WHERE \"category_id\" = @id::int;";
            execute(Crud.sql, "Delete", "parentCat");
            MessageBox.Show("The record has been deleted ", "Delete parent category", MessageBoxButtons.OK, MessageBoxIcon.Information);
            parentCatId = "";
            loadData();
        }


        //product parameters setup
        private void paramProduct(string temp)
        {
            string id = getCatId(categoryDropDown.Text.ToString());
            Crud.sql = temp;
            Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            Crud.cmd.Parameters.AddWithValue("name", PName.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("description", description.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("UnitPrice", UnitPrice.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("discount", discount.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("UnitsInStock", unitsInStock.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("category_id",id.Trim() );
            Crud.cmd.Parameters.AddWithValue("supplier_id", SupplierDropDown.Text.Trim());

        }

        //category parameters setup
        private void paramCat(string temp)
        {
            string pcid = getParentCatId(ParentCatDropDown.Text.ToString());
            Crud.sql = temp;
            Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            Crud.cmd.Parameters.AddWithValue("name", catName.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("description", description.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("nmbr_products", nmbrProd.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("parentCategory_id", pcid.Trim());

        }

        // Order Item parameter setup
        private void paramOrder()
        {
            Crud.cmd.Parameters.AddWithValue("quantity", quantity.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("discount", disc.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("shippingDate", dateTimePickerShip.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("deliveryDate", dateTimePickerShip.Text.Trim());
        }
        //supplier parameters setup
        private void paramSupplier()
        {
            Crud.cmd.Parameters.AddWithValue("firstName", fNameFieldSuppl.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("lastName", lNameFieldSuppl.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("email", emailFieldSuppl.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("city", cityFieldSuppl.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("country", countryFieldSuppl.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("postalCode", pCodeFieldSuppl.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("address", addrFieldSuppl.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("phone", phoneFieldSuppl.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("companyName", companyNameSuppl.Text.Trim());
        }

        //parent category parameters setup
        private void paramParentCat()
        {
            Crud.cmd.Parameters.AddWithValue("name", parentCatName.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("description", parentCatDesciption.Text.Trim());
            Crud.cmd.Parameters.AddWithValue("nmbr_categories", subCatNmbr.Text.Trim());
        }



        private string getCatId(string name)
        {
            Crud.sql = "SELECT \"category_id\" FROM \"public\".\"Category\" WHERE \"name\" = @cn  ";
            Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            Crud.cmd.Parameters.AddWithValue("cn", name);          
            DataTable dt = Crud.PerformCRUD(Crud.cmd);
            string id = Convert.ToString(dt.Rows[0]["category_id"]);
            return id;
        }
        private string getParentCatId(string name)
        {           
            Crud.sql = "SELECT * FROM \"public\".\"ParentCategory\" WHERE \"name\" = @pcn";
            Crud.cmd = new NpgsqlCommand(Crud.sql, Crud.con);
            Crud.cmd.Parameters.AddWithValue("pcn", name);
            DataTable dt = Crud.PerformCRUD(Crud.cmd);
            return Convert.ToString(dt.Rows[0]["category_id"]);
        }
        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }


        private void groupBox1_Enter(object sender, EventArgs e)
        {

        }

        private void tabPage2_Click(object sender, EventArgs e)
        {

        }

        private void groupBox2_Enter(object sender, EventArgs e)
        {

        }

        private void label26_Click(object sender, EventArgs e)
        {

        }

        private void groupBox4_Enter(object sender, EventArgs e)
        {

        }

        private void label29_Click(object sender, EventArgs e)
        {

        }

        private void categoryDropDown_SelectedIndexChanged(object sender, EventArgs e)
        {
            
        }

        private void ParentCatDropDown_SelectedIndexChanged(object sender, EventArgs e)
        {

        }


    }
}
