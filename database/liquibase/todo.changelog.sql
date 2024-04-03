-- liquibase formatted sql
-- changeset phamvant:1712162226815-1
CREATE TYPE permission AS ENUM (
  'PERMISSION_0000',
  'PERMISSION_1111',
  'PERMISSION_2222'
);
CREATE TABLE "User" (
  "user_id" VARCHAR(36) NOT NULL,
  "user_email" VARCHAR(30) NOT NULL,
  "user_name" VARCHAR(30) NOT NULL,
  "user_password" VARCHAR(50) NOT NULL,
  "user_username" VARCHAR(30) NOT NULL,
  "user_verified" BOOLEAN NOT NULL,
  "user_status" VARCHAR(10) NOT NULL,
  "user_roles" VARCHAR [],
  CONSTRAINT "User_pkey" PRIMARY KEY ("user_id")
);
-- changeset phamvant:1712162226815-2
CREATE TABLE "KeyToken" (
  "keytoken_user_id" VARCHAR(36) NOT NULL,
  "keytoken_public_key" TEXT NOT NULL,
  "keytoken_used_refresh_token" TEXT [],
  CONSTRAINT "KeyToken_pkey" PRIMARY KEY ("keytoken_user_id")
);
-- changeset phamvant:1712162226815-3
CREATE TABLE "Product" (
  "product_id" VARCHAR(36) NOT NULL,
  "product_category_id" INTEGER NOT NULL,
  "product_shop_id" VARCHAR NOT NULL,
  "product_name" TEXT NOT NULL,
  "product_thumb" TEXT NOT NULL,
  "product_description" TEXT NOT NULL,
  "product_price" FLOAT8 NOT NULL,
  "product_rating" FLOAT8 DEFAULT '4.5' NOT NULL,
  "product_slug" TEXT,
  "product_isdraft" BOOLEAN DEFAULT TRUE,
  "product_ispublished" BOOLEAN DEFAULT FALSE,
  CONSTRAINT "Product_pkey" PRIMARY KEY ("product_id")
);
-- changeset phamvant:1712162226815-4
CREATE TABLE "Category" (
  "category_id" INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 3) NOT NULL,
  "category_name" VARCHAR(50) NOT NULL,
  "category_parent_id" INTEGER,
  CONSTRAINT "Category_pkey" PRIMARY KEY ("category_id")
);
-- changeset phamvant:1712162226815-5
CREATE TABLE "Variation" (
  "variation_id" INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 7) NOT NULL,
  "variation_name" VARCHAR(100) NOT NULL,
  "variation_value" VARCHAR(50) NOT NULL,
  "variation_shop_id" VARCHAR(36),
  CONSTRAINT "Variation_pkey" PRIMARY KEY ("variation_id")
);
-- changeset phamvant:1712162226815-6
CREATE TABLE "ProductVariation" (
  "product_variation_id" INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "product_variation_product_id" VARCHAR(36),
  "product_variation_variation_id" INTEGER NOT NULL,
  CONSTRAINT "ProductVariation_pkey" PRIMARY KEY ("product_variation_id")
);
-- changeset phamvant:1712162226815-7
CREATE TABLE "CategoryVariation" (
  "category_variation_id" INTEGER GENERATED BY DEFAULT AS IDENTITY (START WITH 7) NOT NULL,
  "category_variation_category_id" INTEGER NOT NULL,
  "category_variation_variation_id" INTEGER NOT NULL,
  CONSTRAINT "CategoryVariation_pkey" PRIMARY KEY ("category_variation_id")
);
-- changeset phamvant:1712162226815-8
CREATE TABLE "Inventory" (
  "inventory_id" INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "inventory_product_id" VARCHAR(36) NOT NULL,
  "inventory_quantity" INTEGER NOT NULL,
  "inventory_created_at" TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
  "inventory_updated_at" TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
  CONSTRAINT "Inventory_pkey" PRIMARY KEY ("inventory_id")
);
-- changeset phamvant:1712162226815-9
CREATE TABLE "DiscountProduct" (
  "discount_product_id" INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "discount_product_discount_id" INTEGER NOT NULL,
  "discount_product_product_id" VARCHAR(36) NOT NULL,
  CONSTRAINT "DiscountProduct_pkey" PRIMARY KEY ("discount_product_id")
);
-- changeset phamvant:1712162226815-10
CREATE TABLE "CartProduct" (
  "cart_product_id" INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "cart_product_cart_id" INTEGER NOT NULL,
  "cart_product_product_id" VARCHAR(36) NOT NULL,
  "cart_product_quantity" INTEGER DEFAULT 1 NOT NULL,
  "cart_product_created_at" TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
  "cart_product_updated_at" TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
  CONSTRAINT "CartProduct_pkey" PRIMARY KEY ("cart_product_id")
);
-- changeset phamvant:1712162226815-11
CREATE TABLE "ApiKey" (
  "apikey_key" VARCHAR(100) NOT NULL,
  "apikey_status" BOOLEAN DEFAULT TRUE,
  "apikey_permission" PERMISSION [],
  CONSTRAINT "ApiKey_pkey" PRIMARY KEY ("apikey_key")
);
-- changeset phamvant:1712162226815-12
CREATE UNIQUE INDEX "User_email_key" ON "User"("user_email");
-- changeset phamvant:1712162226815-13
CREATE INDEX "idx_product_fts" ON "Product"(
  to_tsvector(
    'english'::regconfig,
    (
      (product_name || ' '::text) || product_description
    )
  )
);
-- changeset phamvant:1712162226815-14
CREATE TYPE t_discount_type AS ENUM ('fixed_amout', 'other');
CREATE TYPE t_discount_applies_to AS ENUM ('all', 'specific');
CREATE TABLE "Discount" (
  "discount_id" INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "discount_name" TEXT NOT NULL,
  "discount_description" TEXT NOT NULL,
  "discount_type" T_DISCOUNT_TYPE NOT NULL,
  "discount_value" FLOAT8 NOT NULL,
  "discount_code" VARCHAR(50),
  "discount_start_date" TIMESTAMP(3) WITHOUT TIME ZONE NOT NULL,
  "discount_end_date" TIMESTAMP(3) WITHOUT TIME ZONE NOT NULL,
  "discount_max_uses" INTEGER NOT NULL,
  "discount_uses_count" INTEGER DEFAULT 0 NOT NULL,
  "discount_users_used" INTEGER DEFAULT 0 NOT NULL,
  "discount_max_uses_per_user" INTEGER NOT NULL,
  "discount_min_order_value" INTEGER,
  "discount_shop_id" VARCHAR(36) NOT NULL,
  "discount_is_active" BOOLEAN DEFAULT FALSE NOT NULL,
  "discount_applies_to" T_DISCOUNT_APPLIES_TO NOT NULL,
  CONSTRAINT "Discount_pkey" PRIMARY KEY ("discount_id")
);
-- changeset phamvant:1712162226815-15
CREATE TYPE t_cart_state_type AS enum (
  'active',
  'completed',
  'failed',
  'pending'
);
CREATE TABLE "Cart" (
  "cart_id" INTEGER GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "cart_state" T_CART_STATE_TYPE DEFAULT 'active',
  "cart_user_id" VARCHAR(36) NOT NULL,
  "cart_total" INTEGER DEFAULT 0 NOT NULL,
  CONSTRAINT "Cart_pkey" PRIMARY KEY ("cart_id")
);
-- changeset phamvant:1712162226815-16
ALTER TABLE "Category"
ADD CONSTRAINT "Category_category_parent_id_fkey" FOREIGN KEY ("category_parent_id") REFERENCES "Category" ("category_id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- changeset phamvant:1712162226815-17
ALTER TABLE "KeyToken"
ADD CONSTRAINT "KeyToken_fkey" FOREIGN KEY ("keytoken_user_id") REFERENCES "User" ("user_id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- changeset phamvant:1712162226815-18
ALTER TABLE "Cart"
ADD CONSTRAINT "cart_fkey" FOREIGN KEY ("cart_user_id") REFERENCES "User" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION;
-- changeset phamvant:1712162226815-19
ALTER TABLE "CartProduct"
ADD CONSTRAINT "cart_product_fkey" FOREIGN KEY ("cart_product_cart_id") REFERENCES "Cart" ("cart_id") ON UPDATE NO ACTION ON DELETE NO ACTION;
-- changeset phamvant:1712162226815-20
ALTER TABLE "CartProduct"
ADD CONSTRAINT "cart_product_fkey_2" FOREIGN KEY ("cart_product_product_id") REFERENCES "Product" ("product_id") ON UPDATE NO ACTION ON DELETE NO ACTION;
-- changeset phamvant:1712162226815-21
ALTER TABLE "CategoryVariation"
ADD CONSTRAINT "category_variation_fk" FOREIGN KEY ("category_variation_category_id") REFERENCES "Category" ("category_id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- changeset phamvant:1712162226815-22
ALTER TABLE "CategoryVariation"
ADD CONSTRAINT "category_variation_fk_2" FOREIGN KEY ("category_variation_variation_id") REFERENCES "Variation" ("variation_id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- changeset phamvant:1712162226815-23
ALTER TABLE "Discount"
ADD CONSTRAINT "discount_fk_1" FOREIGN KEY ("discount_shop_id") REFERENCES "User" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION;
-- changeset phamvant:1712162226815-24
ALTER TABLE "DiscountProduct"
ADD CONSTRAINT "discount_product_fk1" FOREIGN KEY ("discount_product_product_id") REFERENCES "Product" ("product_id") ON UPDATE NO ACTION ON DELETE NO ACTION;
-- changeset phamvant:1712162226815-25
ALTER TABLE "DiscountProduct"
ADD CONSTRAINT "discount_product_fk2" FOREIGN KEY ("discount_product_discount_id") REFERENCES "Discount" ("discount_id") ON UPDATE NO ACTION ON DELETE NO ACTION;
-- changeset phamvant:1712162226815-26
ALTER TABLE "Product"
ADD CONSTRAINT "product_category_fk" FOREIGN KEY ("product_category_id") REFERENCES "Category" ("category_id") ON UPDATE NO ACTION ON DELETE NO ACTION;
-- changeset phamvant:1712162226815-27
ALTER TABLE "Inventory"
ADD CONSTRAINT "product_inventory_fkey" FOREIGN KEY ("inventory_product_id") REFERENCES "Product" ("product_id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- changeset phamvant:1712162226815-28
ALTER TABLE "Product"
ADD CONSTRAINT "product_shop_fk" FOREIGN KEY ("product_shop_id") REFERENCES "User" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION;
-- changeset phamvant:1712162226815-29
ALTER TABLE "ProductVariation"
ADD CONSTRAINT "product_variation_fk" FOREIGN KEY ("product_variation_product_id") REFERENCES "Product" ("product_id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- changeset phamvant:1712162226815-30
ALTER TABLE "ProductVariation"
ADD CONSTRAINT "product_variation_fk_2" FOREIGN KEY ("product_variation_variation_id") REFERENCES "Variation" ("variation_id") ON UPDATE NO ACTION ON DELETE CASCADE;
-- changeset phamvant:1712162226815-31
ALTER TABLE "Variation"
ADD CONSTRAINT "variation_shop_fk" FOREIGN KEY ("variation_shop_id") REFERENCES "User" ("user_id") ON UPDATE NO ACTION ON DELETE NO ACTION;