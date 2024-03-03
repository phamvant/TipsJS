import _ from "lodash";
import { v4 as uuidv4 } from "uuid";
import {
  BadRequestError,
  NotFoundError,
  ServerUnavailableError,
} from "../../core/error.response";
import { getQueryParams } from "../../utils";

export class Product {
  product_name: string;
  product_thumbs: string;
  product_description: string;
  product_price: number;
  product_quantity: number;
  product_shop: number;
  product_slug?: string;
  product_rating?: number;
  product_variations: number[];

  isDraft?: boolean;
  isPublished?: boolean;
  //Top Comment

  constructor({
    product_name,
    product_thumbs,
    product_description,
    product_price,
    product_quantity,
    product_variations,
    product_shop,
  }: any) {
    this.product_shop = product_shop;
    this.product_name = product_name;
    this.product_thumbs = product_thumbs;
    this.product_description = product_description;
    this.product_price = product_price;
    this.product_quantity = product_quantity;
    this.product_variations = product_variations;
  }

  /**
   * Create new product
   */
  async createProduct(category_id: number) {
    const product_id = uuidv4();

    //Create connect for transaction
    const client = await postgres.connect().catch((e) => {
      throw new ServerUnavailableError({ message: e as string });
    });

    try {
      await client.query("BEGIN");

      /**
       * Create Product Record
       */
      await client.query({
        text: `INSERT INTO "Product"(id, category_id, shop_id, name, thumb, description, price, slug)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8);
        `,
        values: [
          product_id,
          category_id,
          this.product_shop,
          this.product_name,
          this.product_thumbs,
          this.product_description,
          this.product_price,
          _.kebabCase(this.product_name).toString(),
        ],
      });

      /**
       * Create Product_Variation Record
       */
      await client.query({
        text: `INSERT INTO "ProductVariation" (product_id, variation_id)
      VALUES ${getQueryParams(this.product_variations.length, 2)}`,
        values: this.product_variations.reduce((returnValue, currentValue) => {
          return [...returnValue, ...[product_id, currentValue]];
        }, [] as any[]),
      });

      /**
       * Create Inventory Record
       */
      await client.query({
        text: `INSERT INTO "Inventory"(product_id, quantity)
           VALUES ($1, $2)`,
        values: [product_id, this.product_quantity],
      });

      await client.query("COMMIT");
    } catch (error) {
      await client.query("ROLLBACK");
      throw new ServerUnavailableError({
        message: "Query failed at createProduct",
      });
    }

    return { product_name: this.product_name };
  }

  static getAllDraftOfShop = async ({ shop_id }: { shop_id: string }) => {
    const draftProduct = await postgres
      .query({
        text: `SELECT "Product".*
      FROM "Product", "User"
      WHERE "Product"."shop_id" = "User"."id"
      AND "Product"."shop_id" = $1 AND "Product"."isdraft" = TRUE`,
        values: [shop_id],
      })
      .catch((error) => {
        console.log(error);
        throw new NotFoundError({ message: "Not found draft" });
      });

    const products = draftProduct.rows.reduce((previousValue, currentValue) => {
      const { isdraft, ispublished, ...rest } = currentValue;
      previousValue.push(rest);
      return previousValue;
    }, []);

    return { length: draftProduct.rowCount, products: products };
  };

  static getAllPublishedOfShop = async ({ shop_id }: { shop_id: string }) => {
    const publishedProduct = await postgres
      .query({
        text: `SELECT "Product".*
      FROM "Product", "User"
      WHERE "Product"."shop_id" = "User"."id"
      AND "Product"."shop_id" = $1 AND "Product"."ispublished" = TRUE`,
        values: [shop_id],
      })
      .catch((error) => {
        console.log(error);
        throw new NotFoundError({ message: "Not found published" });
      });

    const products = publishedProduct.rows.reduce(
      (previousValue, currentValue) => {
        const { isdraft, ispublished, ...rest } = currentValue;
        previousValue.push(rest);
        return previousValue;
      },
      []
    );

    return { length: publishedProduct.rowCount, products: products };
  };

  static publishProduct = async ({
    shop_id,
    product_id,
  }: {
    shop_id: string;
    product_id: string;
  }) => {
    await postgres
      .query({
        text: `UPDATE "Product"
        SET "ispublished" = TRUE, "isdraft" = FALSE
        WHERE "shop_id" = $1 
        AND "id" = $2`,
        values: [shop_id, product_id],
      })
      .catch((error) => {
        console.log(error);
        throw new BadRequestError({ message: "Cant publish product" });
      });

    return { product_id };
  };

  static unPublishProduct = async ({
    shop_id,
    product_id,
  }: {
    shop_id: string;
    product_id: string;
  }) => {
    await postgres
      .query({
        text: `UPDATE "Product"
        SET "ispublished" = FALSE, "isdraft" = TRUE
        WHERE "shop_id" = $1 
        AND "id" = $2`,
        values: [shop_id, product_id],
      })
      .catch((error) => {
        console.log(error);
        throw new BadRequestError({ message: "Cant unpublish product" });
      });

    return { product_id };
  };
}