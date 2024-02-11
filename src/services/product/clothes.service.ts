import { v4 as uuidv4 } from "uuid";
import { BadRequestError } from "../../core/error.response";
import { Product } from "./index.service";

export class Clothes extends Product {
  constructor({
    product_name,
    product_thumbs,
    product_description,
    product_price,
    product_quantity,
    product_attribute,
    product_shop,
  }: any) {
    super({
      product_name,
      product_thumbs,
      product_description,
      product_price,
      product_quantity,
      product_attribute,
      product_shop,
    });
  }

  async createProduct() {
    const productId = uuidv4();

    const newClothes = await postgres.query({
      text: `INSERT INTO "Clothes"(id, brand, size, material)
     VALUES ($1, $2, $3, $4);
     `,
      values: [
        productId,
        this.product_attribute.brand,
        this.product_attribute.size,
        this.product_attribute.material,
      ],
    });

    if (!newClothes.rowCount) {
      throw new BadRequestError({ message: "Cant save clothes" });
    }

    const newProductName = await super.createProduct(productId);

    if (!newProductName) {
      throw new BadRequestError({ message: "Cant save product" });
    }

    return newProductName;
  }
}
