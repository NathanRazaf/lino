// books_list.dart
import 'package:flutter/material.dart';
import 'package:Lino_app/services/book_services.dart';

import '../Books/book_details_page.dart';

class BooksList extends StatelessWidget {
  final String query;

  BooksList({required this.query});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: BookService().searchBooks(kw: query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!['books'].isEmpty) {
          return Center(child: Text('No books found.'));
        }

        final books = snapshot.data!['books'];
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final bbid = (book['bookboxPresence'] != null && book['bookboxPresence'].isNotEmpty)
                ? book['bookboxPresence'][0]
                : '';

            return FutureBuilder<Map<String, dynamic>>(
              future: (bbid.isNotEmpty) ? BookService().getBookBox(bbid) : null,
              builder: (context, bbSnapshot) {
                String bookboxStatus = 'Currently not in a bookbox';
                if (bbSnapshot.connectionState == ConnectionState.waiting) {
                  bookboxStatus = 'Loading...';
                } else if (bbSnapshot.hasError) {
                  bookboxStatus = 'Error loading bookbox';
                } else if (bbSnapshot.hasData && bbSnapshot.data != null) {
                  bookboxStatus = 'In bookbox "${bbSnapshot.data!['name']}"';
                }

                return Card(
                  color: Colors.blueGrey[50],
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: Image.network(
                      book['coverImage'],
                      fit: BoxFit.cover,
                      width: 50,
                      height: 75,
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                        return Container(
                          width: 50,
                          height: 75,
                          color: Colors.grey,
                          child: Center(
                            child: Text(
                              book['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
                    title: Text(
                      book['title'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      book['authors'].join(', '),
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    trailing: SizedBox(
                      width: 120,
                      child: Text(
                        bookboxStatus,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => BookDetailsPage(book: book, bbid: bbid),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
