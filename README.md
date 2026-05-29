# Blue Apron Schema

Design and implement a Postgres schema for a simplified Blue Apron — the focus today is modeling **subscriptions** (a user has an ongoing plan that delivers recipes on a schedule) and **recipe ingredients** (a true many-to-many relationship with quantities).

> If you did Saturday's [Schema Design](https://github.com/CP-Evenings-and-Weekends/schema-design) challenge, you already drew an ERD for Blue Apron.  **Pull that diagram back up** as your starting point — today's job is to turn it into actual Postgres tables, seed it, and query it.  If you skipped Blue Apron on Saturday, do the ERD now first.

The included `init.sql`, `Dockerfile`, and `setup.sh` are wired up like [cars-database](https://github.com/CP-Evenings-and-Weekends/cars-database).

## Feature set to support

Aim for Blue Apron's launch features:

- **Users** sign up with name, email, password, and a delivery address
- **Service plans** — different subscription tiers (e.g. 2-person vs. 4-person, 2 vs. 4 meals/week, with prices)
- Each user has **one active service plan** at a time (and a subscription history)
- **Recipes** have a name, prep time, difficulty, instructions, and an image URL
- **Ingredients** have a name and a unit (oz, cups, tbsp, count)
- Each recipe uses **many ingredients in specific quantities** (recipes ↔ ingredients is many-to-many with a `quantity` payload)
- **Deliveries** — a user's weekly box, containing several recipes
- **Promotions** — discount codes that users can apply to a delivery

## Requirements

### 1. Confirm or revise the ERD

Use Saturday's diagram (or build one now) in [dbdiagram.io](https://dbdiagram.io/) or [Quick Database Diagrams](https://www.quickdatabasediagrams.com/).  Commit a screenshot as `erd.png` or a Mermaid `erDiagram` block as `erd.md`.

Likely tables: `users`, `addresses`, `service_plans`, `subscriptions`, `recipes`, `ingredients`, `recipe_ingredients` (join with `quantity`), `deliveries`, `delivery_recipes` (join), `promotions`, `delivery_promotions` (join).

### 2. Implement in `init.sql`

Translate the ERD into `CREATE TABLE` statements.  Conventions from Saturday: plural lowercase table names, `id` primary keys, `_id` foreign keys.

The interesting join table for today is `recipe_ingredients` — it has the join *plus* an `amount` and links to a `unit` (so "2 cups flour" can be modeled cleanly):

```sql
CREATE TABLE recipe_ingredients (
  recipe_id      INT REFERENCES recipes(id),
  ingredient_id  INT REFERENCES ingredients(id),
  amount         NUMERIC NOT NULL,
  unit           VARCHAR(20) NOT NULL,
  PRIMARY KEY (recipe_id, ingredient_id)
);
```

### 3. Seed it with data

2-3 rows per table is enough, but make sure your data exercises the interesting cases:
- At least one user with a current subscription *and* an expired one in their history
- At least one recipe with 4+ ingredients
- At least one delivery containing 2-3 recipes
- At least one promotion applied to a delivery

### 4. Build, run, and query

```bash
./setup.sh
```

Write at least 5 queries in `queries.sql`:

1. All recipes that include a given ingredient (e.g. "salt")
2. The total grocery list for one upcoming delivery (sum ingredient amounts across the delivery's recipes)
3. A given user's current service plan and the delivery cadence
4. Every recipe ever delivered to a given user across all their deliveries
5. Revenue per service plan over the last 90 days

## Things to think about
- A recipe's ingredient quantities are specific (`2 cups flour`, `1 tsp salt`).  Where does the unit live — on `ingredients` or on `recipe_ingredients`?  What changes if you allow flour to be measured in cups *or* grams across different recipes?
- A user's subscription can change over time (upgrade, downgrade, cancel, restart).  Do you mutate a single row, or insert a new `subscriptions` row each time?  What does each give up?
- A promotion has a start date and an expiration.  Where do you enforce "promo must still be valid when applied" — at the schema level (constraints, triggers), or in application code?
- Delivery contents vs. recipe contents: if a recipe is updated next month, should past deliveries show the old version or the new?

## Stretch
- Add **ratings/reviews** — a user can rate a recipe 1-5 with optional text.  Add a query for "top 5 highest-rated recipes."
- Add a **substitutions** table — allow a user to swap ingredients (allergy or preference reasons).  Apply it when generating their delivery's grocery list.
- Add an **index** on `recipe_ingredients.ingredient_id`, then `EXPLAIN ANALYZE` query 1 before and after.
- Use a generated column or view to expose each subscription's `monthly_cost` derived from the service plan.

> Stuck? Have a code error? Use the ["4 Before Me"](https://docs.google.com/document/d/1nseOs5oabYBKNHfwJZNAR7GlU0zkZxNagsw63AD7XV0/edit) debugging checklist to help you solve it!
