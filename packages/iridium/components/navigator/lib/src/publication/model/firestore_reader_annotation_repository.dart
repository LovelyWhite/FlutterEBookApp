import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mno_commons/utils/predicate.dart';
import 'package:mno_navigator/epub.dart';
import 'package:mno_navigator/publication.dart';
import 'package:mno_shared/publication.dart';

class FirestoreReaderAnnotationRepository extends ReaderAnnotationRepository {
  static const String _collectionName = "reader_annotations";
  
  final String _bookId;
  final FirebaseFirestore _firestore;
  ReaderAnnotation? position;

  FirestoreReaderAnnotationRepository(this._bookId, this._firestore);

  // Get collection reference for current book
  CollectionReference<Map<String, dynamic>> get _collection => 
      _firestore.collection(_collectionName).doc(_bookId).collection('annotations');

  // Helper method to convert Firestore document to ReaderAnnotation
  ReaderAnnotation _fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ReaderAnnotation(
      doc.id,
      data['bookId'] as String,
      data['location'] as String,
      AnnotationType.from(data['annotationType'] as int),
      annotation: data['annotation'] as String?,
      style: HighlightStyle.from(data['style'] as int?),
      tint: data['tint'] as int?,
    );
  }

  // Helper method to convert ReaderAnnotation to Firestore document
  Map<String, dynamic> _toDocument(ReaderAnnotation annotation) => {
    'bookId': annotation.bookId,
    'location': annotation.location,
    'annotationType': annotation.annotationType.id,
    if (annotation.annotation != null) 'annotation': annotation.annotation,
    if (annotation.style != null) 'style': annotation.style!.id,
    if (annotation.tint != null) 'tint': annotation.tint,
  };

  @override
  Future<List<ReaderAnnotation>> allWhere({
    Predicate<ReaderAnnotation> predicate = const AcceptAllPredicate()
  }) async {
    final snapshot = await _collection.get();
    final annotations = snapshot.docs.map(_fromDocument).toList();
    return annotations.where(predicate.test).toList();
  }

  @override
  Future<ReaderAnnotation> createBookmark(PaginationInfo paginationInfo) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    ReaderAnnotation readerAnnotation = ReaderAnnotation(
      id,
      _bookId,
      paginationInfo.locator.json,
      AnnotationType.bookmark
    );
    
    await _collection.doc(id).set(_toDocument(readerAnnotation));
    
    notifyBookmark(readerAnnotation);
    return readerAnnotation;
  }

  @override
  Future<ReaderAnnotation> createHighlight(
    PaginationInfo? paginationInfo,
    Locator locator,
    HighlightStyle? style,
    int? tint,
    String? annotation
  ) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    ReaderAnnotation readerAnnotation = ReaderAnnotation(
      id,
      _bookId,
      locator.json,
      AnnotationType.highlight,
      style: style,
      tint: tint,
      annotation: annotation,
    );
    
    await _collection.doc(id).set(_toDocument(readerAnnotation));
    return readerAnnotation;
  }

  @override
  Future<ReaderAnnotation?> get(String id) async {
    final doc = await _collection.doc(id).get();
    return doc.exists ? _fromDocument(doc) : null;
  }

  @override
  Future<ReaderAnnotation?> getPosition() async => position;

  @override
  Future<ReaderAnnotation> savePosition(PaginationInfo paginationInfo) async {
    String id = "position-$_bookId";
    ReaderAnnotation readerAnnotation = ReaderAnnotation(
      id,
      _bookId,
      paginationInfo.locator.json,
      AnnotationType.bookmark
    );
    
    await _collection.doc(id).set(_toDocument(readerAnnotation));
    
    position = readerAnnotation;
    return readerAnnotation;
  }

  @override
  void save(ReaderAnnotation readerAnnotation) async {
    await _collection.doc(readerAnnotation.id).update(_toDocument(readerAnnotation));
  }

  @override
  Future<void> delete(Iterable<String> deletedIds) async {
    final batch = _firestore.batch();
    for (final id in deletedIds) {
      batch.delete(_collection.doc(id));
    }
    await batch.commit();
    
    super.delete(deletedIds);
  }
} 