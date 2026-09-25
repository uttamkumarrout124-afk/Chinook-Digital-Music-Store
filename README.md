## 🎯 Project Objective

The objective of this project is to analyze the Chinook Digital Music Store database and convert transaction-level data into meaningful business insights.

The analysis focuses on:

- Data quality and completeness
- Sales and revenue performance
- Customer purchasing behavior
- Customer churn and retention
- Top-performing tracks, artists, albums, and genres
- Geographic market performance
- High-value customer identification
- Revenue and cross-selling opportunities

The project covers 21 business questions using customer, invoice, track, album, artist, and genre data. :contentReference[oaicite:0]{index=0}

---

## 🔍 Approach & Techniques Used

The analysis follows a structured SQL-based approach:

- Performed NULL and duplicate checks to validate data quality
- Used multi-table JOINs to connect Customer, Invoice, Invoice Line, Track, Album, Artist, and Genre tables
- Applied aggregate functions to calculate revenue, purchase frequency, Average Order Value, and basket size
- Used `GROUP BY`, subqueries, and CTEs for business-level analysis
- Applied `DENSE_RANK()` to identify top customers within each country
- Used `ROW_NUMBER()` to identify individual customer track preferences
- Performed geographic analysis by country, state, and city
- Conducted customer churn analysis using purchase recency
- Analyzed genre, artist, and track performance
- Evaluated customer behavior for retention and cross-selling opportunities

The project used **SQL for analysis** and **PowerPoint for management-level reporting and visualization**. :contentReference[oaicite:1]{index=1}

---

## 📊 Key Outcomes

The analysis covered:

- **59 customers**
- **24 countries**
- **614 invoices**
- **3,503 tracks**
- **347 albums**
- **275 artists**
- **25 genres**
- **$4,709.43 total revenue** :contentReference[oaicite:2]{index=2}

Key findings include:

- No duplicate primary keys or duplicate customer records were identified
- USA was the leading individual market by customer count and revenue
- Rock was the dominant genre in the USA
- High-value customers were identified across multiple countries
- Customer purchasing behavior was measured using purchase frequency, AOV, and basket size
- Year-wise churn trends were identified for customer retention analysis
- Individual customer track preferences were identified for personalization opportunities :contentReference[oaicite:3]{index=3}

---

## 💼 Benefit to Top Management

This analysis provides management with a clear view of customer, sales, and product performance to support better business decisions.

### Key management benefits:

- **Revenue Prioritization** – Identify high-performing markets, artists, genres, and customer segments
- **Customer Retention** – Detect high-value customers at risk of churn and plan targeted win-back actions
- **Marketing Focus** – Allocate marketing effort toward stronger genres, artists, and geographic markets
- **Customer Segmentation** – Differentiate high-value, frequent, and low-engagement customers
- **Cross-Selling** – Use customer track and genre preferences to support personalized recommendations
- **Market Expansion** – Identify countries with strong revenue potential for future growth
- **Data Quality Improvement** – Highlight missing or incomplete fields that can affect reporting quality
- **Leadership Visibility** – Convert raw SQL data into concise business insights that management can act on

The project demonstrates how SQL analytics can support management decisions in **revenue growth, customer retention, marketing strategy, customer experience, and business planning**.
