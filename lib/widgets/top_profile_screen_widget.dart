import 'package:agro_nepal/providers/profile_provider.dart';
import 'package:agro_nepal/utilities/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopProfileScreenWidget extends StatelessWidget {
  const TopProfileScreenWidget({
    Key? key,
    required this.sizeQuery,
  }) : super(key: key);

  final Size sizeQuery;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      left: 0,
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
          top: 20,
        ),
        height: sizeQuery.height * 0.2,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(
              200,
            ),
          ),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.lightGreen,
              ThemeClass.primaryColor,
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                backgroundColor: Colors.black12,
                radius: 43,
                backgroundImage: NetworkImage(
                  Provider.of<ProfileProvider>(context).imageUrl,
                ),
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 100,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Provider.of<ProfileProvider>(context).userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      Provider.of<ProfileProvider>(context).email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
