import 'package:agro_nepal/utilities/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatefulWidget {
  // const CartItem({Key? key}) : super(key: key);

  final String id;
  final String productId;
  final String title;
  final String imageUrl;
  final int quantity;
  final double price;

  CartItem(
    this.id,
    this.productId,
    this.title,
    this.imageUrl,
    this.quantity,
    this.price,
  );

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  Widget editButtons(Function onPressed, String text, Color color) {
    return Expanded(
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            color,
          ),
        ),
        onPressed: () {
          onPressed();
        },
        child: Text(text),
      ),
    );
  }

  Widget quantityChangingButtons(Function onPressed, IconData icon) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(
            5,
          ),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  int quantity = 0;
  double price = 0.0;

  @override
  void initState() {
    quantity = widget.quantity;
    price = widget.price * quantity;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(
      context,
      listen: false,
    );

    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(
              8,
            ),
            child: ListTile(
              dense: true,
              leading: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                height: 60,
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  child: Image(
                    image: NetworkImage(
                      widget.imageUrl,
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widget.title,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    '( Rs. ${widget.price} )',
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                'Total: Rs. ${(widget.price * widget.quantity).toStringAsFixed(2)}',
              ),
              trailing: Text('${widget.quantity} X'),
            ),
          ),
        ),
        Positioned(
          right: 60,
          top: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              5,
            ),
            child: Material(
              color: ThemeClass.primaryColor, // button color
              child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onTap: () {
                  showModalBottomSheet(
                    isDismissible: true,
                    enableDrag: false,
                    backgroundColor: Colors.white,
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (ctx, StateSetter setState) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 15,
                            ),
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [ 
                                  CircleAvatar(
                                    radius: 72,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    child: CircleAvatar(
                                      radius: 70,
                                      backgroundImage: NetworkImage(
                                        widget.imageUrl,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '${widget.title} ( Rs. ${widget.price} )',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      quantityChangingButtons(() {
                                        if (quantity == 0) {
                                          return;
                                        } else if (quantity == 1) {
                                          setState(() {
                                            quantity--;
                                            price = 0.0;
                                          });
                                          return;
                                        }
                                        setState(() {
                                          quantity--;
                                          price -= widget.price;
                                        });
                                      }, Icons.remove),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        quantity.toString(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      quantityChangingButtons(
                                        () {
                                          setState(() {
                                            quantity++;
                                            price += widget.price;
                                          });
                                        },
                                        Icons.add,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Total',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Rs. ${price.toStringAsFixed(2)}',
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          editButtons(
                                            () {
                                              Navigator.of(context).pop();
                                              setState(() {
                                                price = widget.price;
                                                quantity = widget.quantity;
                                              });
                                            },
                                            'Cancel',
                                            Colors.redAccent,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          editButtons(
                                            () {
                                              Provider.of<CartProvider>(context,
                                                      listen: false)
                                                  .editSingleCartItem(
                                                widget.productId,
                                                widget.price,
                                                quantity,
                                              );
                                              Navigator.of(context).pop();
                                            },
                                            'Save Changes',
                                            Theme.of(context).primaryColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          top: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              5,
            ),
            child: Material(
              color: Colors.red, // button color
              child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Are you Sure?'),
                        content: const Text(
                          'Do you want to remove the item from the Cart?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              cartData.removeCartItem(widget.productId);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
