import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '/core/app_color.dart';
import '/src/model/product.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/src/view/widget/page_wrapper.dart';
import '/src/view/widget/carousel_slider.dart';
import '/src/controller/product_controller.dart';

final ProductController controller = Get.put(ProductController());

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen(this.product, {Key? key}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _review = '';

  void _updateReview(String value) {
    setState(() {
      _review = value;
    });
  }

  static List<String> reviews = [];
  _addReview() {
    reviews.add(_review);
  }

  Widget _build() {
    if (reviews.length > 0) {
      return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Color.fromARGB(255, 226, 226, 226),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(reviews[index]),
                );
              },
            ),
          ]));
    } else {
      return Container(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 1,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('No Review'),
            );
          },
        ),
      );
    }
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Write your review',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          onChanged: _updateReview,
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            _addReview();
            _showSnackBar();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }

  void _showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Review added successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  Widget productPageView(double width, double height) {
    return Container(
      height: height * 0.42,
      width: width,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(200),
          bottomLeft: Radius.circular(200),
        ),
      ),
      child: CarouselSlider(items: widget.product.images),
    );
  }

  Widget _ratingBar(BuildContext context) {
    return Wrap(
      spacing: 30,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        RatingBar.builder(
          initialRating: widget.product.rating,
          direction: Axis.horizontal,
          itemBuilder: (_, __) => const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (_) {},
        ),
        Text(
          "(4500 Reviews)",
          style: Theme.of(context)
              .textTheme
              .displaySmall
              ?.copyWith(fontWeight: FontWeight.w300),
        )
      ],
    );
  }

  Widget productSizesListView() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: controller.sizeType(widget.product).length,
      itemBuilder: (_, index) {
        return InkWell(
          onTap: () =>
              controller.switchBetweenProductSizes(widget.product, index),
          child: AnimatedContainer(
            margin: const EdgeInsets.only(right: 5, left: 5),
            alignment: Alignment.center,
            width: controller.isNominal(widget.product) ? 40 : 70,
            decoration: BoxDecoration(
              color:
                  controller.sizeType(widget.product)[index].isSelected == false
                      ? Colors.white
                      : AppColor.lightOrange,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey, width: 0.4),
            ),
            duration: const Duration(milliseconds: 300),
            child: FittedBox(
              child: Text(
                controller.sizeType(widget.product)[index].numerical,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _appBar(context),
        body: SingleChildScrollView(
          child: PageWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                productPageView(width, height),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 10),
                      _ratingBar(context),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            widget.product.off != null
                                ? "\$${widget.product.off}"
                                : "\$${widget.product.price}",
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          const SizedBox(width: 3),
                          Visibility(
                            visible: widget.product.off != null ? true : false,
                            child: Text(
                              "\$${widget.product.price}",
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            widget.product.isAvailable
                                ? "Available in stock"
                                : "Not available",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Review",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      _build(),
                      SizedBox(
                        height: 40,
                        child: GetBuilder<ProductController>(
                          builder: (_) => productSizesListView(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.product.isAvailable
                              ? () => controller.addToCart(widget.product)
                              : null,
                          child: const Text("Add to cart"),
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildReviewForm(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
