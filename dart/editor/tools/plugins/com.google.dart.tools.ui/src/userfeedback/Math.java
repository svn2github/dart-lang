// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: userfeedback/proto/math.proto

package userfeedback;

public final class Math {
  private Math() {}
  public static void registerAllExtensions(
      com.google.protobuf.ExtensionRegistry registry) {
  }
  public interface DimensionsOrBuilder
      extends com.google.protobuf.MessageOrBuilder {

    // required float width = 1;
    /**
     * <code>required float width = 1;</code>
     */
    boolean hasWidth();
    /**
     * <code>required float width = 1;</code>
     */
    float getWidth();

    // required float height = 2;
    /**
     * <code>required float height = 2;</code>
     */
    boolean hasHeight();
    /**
     * <code>required float height = 2;</code>
     */
    float getHeight();
  }
  /**
   * Protobuf type {@code userfeedback.Dimensions}
   *
   * <pre>
   * 2D Dimensions.
   * </pre>
   */
  public static final class Dimensions extends
      com.google.protobuf.GeneratedMessage
      implements DimensionsOrBuilder {
    // Use Dimensions.newBuilder() to construct.
    private Dimensions(com.google.protobuf.GeneratedMessage.Builder<?> builder) {
      super(builder);
      this.unknownFields = builder.getUnknownFields();
    }
    private Dimensions(boolean noInit) { this.unknownFields = com.google.protobuf.UnknownFieldSet.getDefaultInstance(); }

    private static final Dimensions defaultInstance;
    public static Dimensions getDefaultInstance() {
      return defaultInstance;
    }

    public Dimensions getDefaultInstanceForType() {
      return defaultInstance;
    }

    private final com.google.protobuf.UnknownFieldSet unknownFields;
    @java.lang.Override
    public final com.google.protobuf.UnknownFieldSet
        getUnknownFields() {
      return this.unknownFields;
    }
    private Dimensions(
        com.google.protobuf.CodedInputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws com.google.protobuf.InvalidProtocolBufferException {
      initFields();
      int mutable_bitField0_ = 0;
      com.google.protobuf.UnknownFieldSet.Builder unknownFields =
          com.google.protobuf.UnknownFieldSet.newBuilder();
      try {
        boolean done = false;
        while (!done) {
          int tag = input.readTag();
          switch (tag) {
            case 0:
              done = true;
              break;
            default: {
              if (!parseUnknownField(input, unknownFields,
                                     extensionRegistry, tag)) {
                done = true;
              }
              break;
            }
            case 13: {
              bitField0_ |= 0x00000001;
              width_ = input.readFloat();
              break;
            }
            case 21: {
              bitField0_ |= 0x00000002;
              height_ = input.readFloat();
              break;
            }
          }
        }
      } catch (com.google.protobuf.InvalidProtocolBufferException e) {
        throw e.setUnfinishedMessage(this);
      } catch (java.io.IOException e) {
        throw new com.google.protobuf.InvalidProtocolBufferException(
            e.getMessage()).setUnfinishedMessage(this);
      } finally {
        this.unknownFields = unknownFields.build();
        makeExtensionsImmutable();
      }
    }
    public static final com.google.protobuf.Descriptors.Descriptor
        getDescriptor() {
      return userfeedback.Math.internal_static_userfeedback_Dimensions_descriptor;
    }

    protected com.google.protobuf.GeneratedMessage.FieldAccessorTable
        internalGetFieldAccessorTable() {
      return userfeedback.Math.internal_static_userfeedback_Dimensions_fieldAccessorTable
          .ensureFieldAccessorsInitialized(
              userfeedback.Math.Dimensions.class, userfeedback.Math.Dimensions.Builder.class);
    }

    public static com.google.protobuf.Parser<Dimensions> PARSER =
        new com.google.protobuf.AbstractParser<Dimensions>() {
      public Dimensions parsePartialFrom(
          com.google.protobuf.CodedInputStream input,
          com.google.protobuf.ExtensionRegistryLite extensionRegistry)
          throws com.google.protobuf.InvalidProtocolBufferException {
        return new Dimensions(input, extensionRegistry);
      }
    };

    @java.lang.Override
    public com.google.protobuf.Parser<Dimensions> getParserForType() {
      return PARSER;
    }

    private int bitField0_;
    // required float width = 1;
    public static final int WIDTH_FIELD_NUMBER = 1;
    private float width_;
    /**
     * <code>required float width = 1;</code>
     */
    public boolean hasWidth() {
      return ((bitField0_ & 0x00000001) == 0x00000001);
    }
    /**
     * <code>required float width = 1;</code>
     */
    public float getWidth() {
      return width_;
    }

    // required float height = 2;
    public static final int HEIGHT_FIELD_NUMBER = 2;
    private float height_;
    /**
     * <code>required float height = 2;</code>
     */
    public boolean hasHeight() {
      return ((bitField0_ & 0x00000002) == 0x00000002);
    }
    /**
     * <code>required float height = 2;</code>
     */
    public float getHeight() {
      return height_;
    }

    private void initFields() {
      width_ = 0F;
      height_ = 0F;
    }
    private byte memoizedIsInitialized = -1;
    public final boolean isInitialized() {
      byte isInitialized = memoizedIsInitialized;
      if (isInitialized != -1) return isInitialized == 1;

      if (!hasWidth()) {
        memoizedIsInitialized = 0;
        return false;
      }
      if (!hasHeight()) {
        memoizedIsInitialized = 0;
        return false;
      }
      memoizedIsInitialized = 1;
      return true;
    }

    public void writeTo(com.google.protobuf.CodedOutputStream output)
                        throws java.io.IOException {
      getSerializedSize();
      if (((bitField0_ & 0x00000001) == 0x00000001)) {
        output.writeFloat(1, width_);
      }
      if (((bitField0_ & 0x00000002) == 0x00000002)) {
        output.writeFloat(2, height_);
      }
      getUnknownFields().writeTo(output);
    }

    private int memoizedSerializedSize = -1;
    public int getSerializedSize() {
      int size = memoizedSerializedSize;
      if (size != -1) return size;

      size = 0;
      if (((bitField0_ & 0x00000001) == 0x00000001)) {
        size += com.google.protobuf.CodedOutputStream
          .computeFloatSize(1, width_);
      }
      if (((bitField0_ & 0x00000002) == 0x00000002)) {
        size += com.google.protobuf.CodedOutputStream
          .computeFloatSize(2, height_);
      }
      size += getUnknownFields().getSerializedSize();
      memoizedSerializedSize = size;
      return size;
    }

    private static final long serialVersionUID = 0L;
    @java.lang.Override
    protected java.lang.Object writeReplace()
        throws java.io.ObjectStreamException {
      return super.writeReplace();
    }

    public static userfeedback.Math.Dimensions parseFrom(
        com.google.protobuf.ByteString data)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data);
    }
    public static userfeedback.Math.Dimensions parseFrom(
        com.google.protobuf.ByteString data,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data, extensionRegistry);
    }
    public static userfeedback.Math.Dimensions parseFrom(byte[] data)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data);
    }
    public static userfeedback.Math.Dimensions parseFrom(
        byte[] data,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data, extensionRegistry);
    }
    public static userfeedback.Math.Dimensions parseFrom(java.io.InputStream input)
        throws java.io.IOException {
      return PARSER.parseFrom(input);
    }
    public static userfeedback.Math.Dimensions parseFrom(
        java.io.InputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws java.io.IOException {
      return PARSER.parseFrom(input, extensionRegistry);
    }
    public static userfeedback.Math.Dimensions parseDelimitedFrom(java.io.InputStream input)
        throws java.io.IOException {
      return PARSER.parseDelimitedFrom(input);
    }
    public static userfeedback.Math.Dimensions parseDelimitedFrom(
        java.io.InputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws java.io.IOException {
      return PARSER.parseDelimitedFrom(input, extensionRegistry);
    }
    public static userfeedback.Math.Dimensions parseFrom(
        com.google.protobuf.CodedInputStream input)
        throws java.io.IOException {
      return PARSER.parseFrom(input);
    }
    public static userfeedback.Math.Dimensions parseFrom(
        com.google.protobuf.CodedInputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws java.io.IOException {
      return PARSER.parseFrom(input, extensionRegistry);
    }

    public static Builder newBuilder() { return Builder.create(); }
    public Builder newBuilderForType() { return newBuilder(); }
    public static Builder newBuilder(userfeedback.Math.Dimensions prototype) {
      return newBuilder().mergeFrom(prototype);
    }
    public Builder toBuilder() { return newBuilder(this); }

    @java.lang.Override
    protected Builder newBuilderForType(
        com.google.protobuf.GeneratedMessage.BuilderParent parent) {
      Builder builder = new Builder(parent);
      return builder;
    }
    /**
     * Protobuf type {@code userfeedback.Dimensions}
     *
     * <pre>
     * 2D Dimensions.
     * </pre>
     */
    public static final class Builder extends
        com.google.protobuf.GeneratedMessage.Builder<Builder>
       implements userfeedback.Math.DimensionsOrBuilder {
      public static final com.google.protobuf.Descriptors.Descriptor
          getDescriptor() {
        return userfeedback.Math.internal_static_userfeedback_Dimensions_descriptor;
      }

      protected com.google.protobuf.GeneratedMessage.FieldAccessorTable
          internalGetFieldAccessorTable() {
        return userfeedback.Math.internal_static_userfeedback_Dimensions_fieldAccessorTable
            .ensureFieldAccessorsInitialized(
                userfeedback.Math.Dimensions.class, userfeedback.Math.Dimensions.Builder.class);
      }

      // Construct using userfeedback.Math.Dimensions.newBuilder()
      private Builder() {
        maybeForceBuilderInitialization();
      }

      private Builder(
          com.google.protobuf.GeneratedMessage.BuilderParent parent) {
        super(parent);
        maybeForceBuilderInitialization();
      }
      private void maybeForceBuilderInitialization() {
        if (com.google.protobuf.GeneratedMessage.alwaysUseFieldBuilders) {
        }
      }
      private static Builder create() {
        return new Builder();
      }

      public Builder clear() {
        super.clear();
        width_ = 0F;
        bitField0_ = (bitField0_ & ~0x00000001);
        height_ = 0F;
        bitField0_ = (bitField0_ & ~0x00000002);
        return this;
      }

      public Builder clone() {
        return create().mergeFrom(buildPartial());
      }

      public com.google.protobuf.Descriptors.Descriptor
          getDescriptorForType() {
        return userfeedback.Math.internal_static_userfeedback_Dimensions_descriptor;
      }

      public userfeedback.Math.Dimensions getDefaultInstanceForType() {
        return userfeedback.Math.Dimensions.getDefaultInstance();
      }

      public userfeedback.Math.Dimensions build() {
        userfeedback.Math.Dimensions result = buildPartial();
        if (!result.isInitialized()) {
          throw newUninitializedMessageException(result);
        }
        return result;
      }

      public userfeedback.Math.Dimensions buildPartial() {
        userfeedback.Math.Dimensions result = new userfeedback.Math.Dimensions(this);
        int from_bitField0_ = bitField0_;
        int to_bitField0_ = 0;
        if (((from_bitField0_ & 0x00000001) == 0x00000001)) {
          to_bitField0_ |= 0x00000001;
        }
        result.width_ = width_;
        if (((from_bitField0_ & 0x00000002) == 0x00000002)) {
          to_bitField0_ |= 0x00000002;
        }
        result.height_ = height_;
        result.bitField0_ = to_bitField0_;
        onBuilt();
        return result;
      }

      public Builder mergeFrom(com.google.protobuf.Message other) {
        if (other instanceof userfeedback.Math.Dimensions) {
          return mergeFrom((userfeedback.Math.Dimensions)other);
        } else {
          super.mergeFrom(other);
          return this;
        }
      }

      public Builder mergeFrom(userfeedback.Math.Dimensions other) {
        if (other == userfeedback.Math.Dimensions.getDefaultInstance()) return this;
        if (other.hasWidth()) {
          setWidth(other.getWidth());
        }
        if (other.hasHeight()) {
          setHeight(other.getHeight());
        }
        this.mergeUnknownFields(other.getUnknownFields());
        return this;
      }

      public final boolean isInitialized() {
        if (!hasWidth()) {
          
          return false;
        }
        if (!hasHeight()) {
          
          return false;
        }
        return true;
      }

      public Builder mergeFrom(
          com.google.protobuf.CodedInputStream input,
          com.google.protobuf.ExtensionRegistryLite extensionRegistry)
          throws java.io.IOException {
        userfeedback.Math.Dimensions parsedMessage = null;
        try {
          parsedMessage = PARSER.parsePartialFrom(input, extensionRegistry);
        } catch (com.google.protobuf.InvalidProtocolBufferException e) {
          parsedMessage = (userfeedback.Math.Dimensions) e.getUnfinishedMessage();
          throw e;
        } finally {
          if (parsedMessage != null) {
            mergeFrom(parsedMessage);
          }
        }
        return this;
      }
      private int bitField0_;

      // required float width = 1;
      private float width_ ;
      /**
       * <code>required float width = 1;</code>
       */
      public boolean hasWidth() {
        return ((bitField0_ & 0x00000001) == 0x00000001);
      }
      /**
       * <code>required float width = 1;</code>
       */
      public float getWidth() {
        return width_;
      }
      /**
       * <code>required float width = 1;</code>
       */
      public Builder setWidth(float value) {
        bitField0_ |= 0x00000001;
        width_ = value;
        onChanged();
        return this;
      }
      /**
       * <code>required float width = 1;</code>
       */
      public Builder clearWidth() {
        bitField0_ = (bitField0_ & ~0x00000001);
        width_ = 0F;
        onChanged();
        return this;
      }

      // required float height = 2;
      private float height_ ;
      /**
       * <code>required float height = 2;</code>
       */
      public boolean hasHeight() {
        return ((bitField0_ & 0x00000002) == 0x00000002);
      }
      /**
       * <code>required float height = 2;</code>
       */
      public float getHeight() {
        return height_;
      }
      /**
       * <code>required float height = 2;</code>
       */
      public Builder setHeight(float value) {
        bitField0_ |= 0x00000002;
        height_ = value;
        onChanged();
        return this;
      }
      /**
       * <code>required float height = 2;</code>
       */
      public Builder clearHeight() {
        bitField0_ = (bitField0_ & ~0x00000002);
        height_ = 0F;
        onChanged();
        return this;
      }

      // @@protoc_insertion_point(builder_scope:userfeedback.Dimensions)
    }

    static {
      defaultInstance = new Dimensions(true);
      defaultInstance.initFields();
    }

    // @@protoc_insertion_point(class_scope:userfeedback.Dimensions)
  }

  public interface RectangleOrBuilder
      extends com.google.protobuf.MessageOrBuilder {

    // required float left = 1;
    /**
     * <code>required float left = 1;</code>
     */
    boolean hasLeft();
    /**
     * <code>required float left = 1;</code>
     */
    float getLeft();

    // required float top = 2;
    /**
     * <code>required float top = 2;</code>
     */
    boolean hasTop();
    /**
     * <code>required float top = 2;</code>
     */
    float getTop();

    // required float width = 3;
    /**
     * <code>required float width = 3;</code>
     */
    boolean hasWidth();
    /**
     * <code>required float width = 3;</code>
     */
    float getWidth();

    // required float height = 4;
    /**
     * <code>required float height = 4;</code>
     */
    boolean hasHeight();
    /**
     * <code>required float height = 4;</code>
     */
    float getHeight();
  }
  /**
   * Protobuf type {@code userfeedback.Rectangle}
   *
   * <pre>
   * Axis-aligned rectangle in 2D space.
   * </pre>
   */
  public static final class Rectangle extends
      com.google.protobuf.GeneratedMessage
      implements RectangleOrBuilder {
    // Use Rectangle.newBuilder() to construct.
    private Rectangle(com.google.protobuf.GeneratedMessage.Builder<?> builder) {
      super(builder);
      this.unknownFields = builder.getUnknownFields();
    }
    private Rectangle(boolean noInit) { this.unknownFields = com.google.protobuf.UnknownFieldSet.getDefaultInstance(); }

    private static final Rectangle defaultInstance;
    public static Rectangle getDefaultInstance() {
      return defaultInstance;
    }

    public Rectangle getDefaultInstanceForType() {
      return defaultInstance;
    }

    private final com.google.protobuf.UnknownFieldSet unknownFields;
    @java.lang.Override
    public final com.google.protobuf.UnknownFieldSet
        getUnknownFields() {
      return this.unknownFields;
    }
    private Rectangle(
        com.google.protobuf.CodedInputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws com.google.protobuf.InvalidProtocolBufferException {
      initFields();
      int mutable_bitField0_ = 0;
      com.google.protobuf.UnknownFieldSet.Builder unknownFields =
          com.google.protobuf.UnknownFieldSet.newBuilder();
      try {
        boolean done = false;
        while (!done) {
          int tag = input.readTag();
          switch (tag) {
            case 0:
              done = true;
              break;
            default: {
              if (!parseUnknownField(input, unknownFields,
                                     extensionRegistry, tag)) {
                done = true;
              }
              break;
            }
            case 13: {
              bitField0_ |= 0x00000001;
              left_ = input.readFloat();
              break;
            }
            case 21: {
              bitField0_ |= 0x00000002;
              top_ = input.readFloat();
              break;
            }
            case 29: {
              bitField0_ |= 0x00000004;
              width_ = input.readFloat();
              break;
            }
            case 37: {
              bitField0_ |= 0x00000008;
              height_ = input.readFloat();
              break;
            }
          }
        }
      } catch (com.google.protobuf.InvalidProtocolBufferException e) {
        throw e.setUnfinishedMessage(this);
      } catch (java.io.IOException e) {
        throw new com.google.protobuf.InvalidProtocolBufferException(
            e.getMessage()).setUnfinishedMessage(this);
      } finally {
        this.unknownFields = unknownFields.build();
        makeExtensionsImmutable();
      }
    }
    public static final com.google.protobuf.Descriptors.Descriptor
        getDescriptor() {
      return userfeedback.Math.internal_static_userfeedback_Rectangle_descriptor;
    }

    protected com.google.protobuf.GeneratedMessage.FieldAccessorTable
        internalGetFieldAccessorTable() {
      return userfeedback.Math.internal_static_userfeedback_Rectangle_fieldAccessorTable
          .ensureFieldAccessorsInitialized(
              userfeedback.Math.Rectangle.class, userfeedback.Math.Rectangle.Builder.class);
    }

    public static com.google.protobuf.Parser<Rectangle> PARSER =
        new com.google.protobuf.AbstractParser<Rectangle>() {
      public Rectangle parsePartialFrom(
          com.google.protobuf.CodedInputStream input,
          com.google.protobuf.ExtensionRegistryLite extensionRegistry)
          throws com.google.protobuf.InvalidProtocolBufferException {
        return new Rectangle(input, extensionRegistry);
      }
    };

    @java.lang.Override
    public com.google.protobuf.Parser<Rectangle> getParserForType() {
      return PARSER;
    }

    private int bitField0_;
    // required float left = 1;
    public static final int LEFT_FIELD_NUMBER = 1;
    private float left_;
    /**
     * <code>required float left = 1;</code>
     */
    public boolean hasLeft() {
      return ((bitField0_ & 0x00000001) == 0x00000001);
    }
    /**
     * <code>required float left = 1;</code>
     */
    public float getLeft() {
      return left_;
    }

    // required float top = 2;
    public static final int TOP_FIELD_NUMBER = 2;
    private float top_;
    /**
     * <code>required float top = 2;</code>
     */
    public boolean hasTop() {
      return ((bitField0_ & 0x00000002) == 0x00000002);
    }
    /**
     * <code>required float top = 2;</code>
     */
    public float getTop() {
      return top_;
    }

    // required float width = 3;
    public static final int WIDTH_FIELD_NUMBER = 3;
    private float width_;
    /**
     * <code>required float width = 3;</code>
     */
    public boolean hasWidth() {
      return ((bitField0_ & 0x00000004) == 0x00000004);
    }
    /**
     * <code>required float width = 3;</code>
     */
    public float getWidth() {
      return width_;
    }

    // required float height = 4;
    public static final int HEIGHT_FIELD_NUMBER = 4;
    private float height_;
    /**
     * <code>required float height = 4;</code>
     */
    public boolean hasHeight() {
      return ((bitField0_ & 0x00000008) == 0x00000008);
    }
    /**
     * <code>required float height = 4;</code>
     */
    public float getHeight() {
      return height_;
    }

    private void initFields() {
      left_ = 0F;
      top_ = 0F;
      width_ = 0F;
      height_ = 0F;
    }
    private byte memoizedIsInitialized = -1;
    public final boolean isInitialized() {
      byte isInitialized = memoizedIsInitialized;
      if (isInitialized != -1) return isInitialized == 1;

      if (!hasLeft()) {
        memoizedIsInitialized = 0;
        return false;
      }
      if (!hasTop()) {
        memoizedIsInitialized = 0;
        return false;
      }
      if (!hasWidth()) {
        memoizedIsInitialized = 0;
        return false;
      }
      if (!hasHeight()) {
        memoizedIsInitialized = 0;
        return false;
      }
      memoizedIsInitialized = 1;
      return true;
    }

    public void writeTo(com.google.protobuf.CodedOutputStream output)
                        throws java.io.IOException {
      getSerializedSize();
      if (((bitField0_ & 0x00000001) == 0x00000001)) {
        output.writeFloat(1, left_);
      }
      if (((bitField0_ & 0x00000002) == 0x00000002)) {
        output.writeFloat(2, top_);
      }
      if (((bitField0_ & 0x00000004) == 0x00000004)) {
        output.writeFloat(3, width_);
      }
      if (((bitField0_ & 0x00000008) == 0x00000008)) {
        output.writeFloat(4, height_);
      }
      getUnknownFields().writeTo(output);
    }

    private int memoizedSerializedSize = -1;
    public int getSerializedSize() {
      int size = memoizedSerializedSize;
      if (size != -1) return size;

      size = 0;
      if (((bitField0_ & 0x00000001) == 0x00000001)) {
        size += com.google.protobuf.CodedOutputStream
          .computeFloatSize(1, left_);
      }
      if (((bitField0_ & 0x00000002) == 0x00000002)) {
        size += com.google.protobuf.CodedOutputStream
          .computeFloatSize(2, top_);
      }
      if (((bitField0_ & 0x00000004) == 0x00000004)) {
        size += com.google.protobuf.CodedOutputStream
          .computeFloatSize(3, width_);
      }
      if (((bitField0_ & 0x00000008) == 0x00000008)) {
        size += com.google.protobuf.CodedOutputStream
          .computeFloatSize(4, height_);
      }
      size += getUnknownFields().getSerializedSize();
      memoizedSerializedSize = size;
      return size;
    }

    private static final long serialVersionUID = 0L;
    @java.lang.Override
    protected java.lang.Object writeReplace()
        throws java.io.ObjectStreamException {
      return super.writeReplace();
    }

    public static userfeedback.Math.Rectangle parseFrom(
        com.google.protobuf.ByteString data)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data);
    }
    public static userfeedback.Math.Rectangle parseFrom(
        com.google.protobuf.ByteString data,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data, extensionRegistry);
    }
    public static userfeedback.Math.Rectangle parseFrom(byte[] data)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data);
    }
    public static userfeedback.Math.Rectangle parseFrom(
        byte[] data,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws com.google.protobuf.InvalidProtocolBufferException {
      return PARSER.parseFrom(data, extensionRegistry);
    }
    public static userfeedback.Math.Rectangle parseFrom(java.io.InputStream input)
        throws java.io.IOException {
      return PARSER.parseFrom(input);
    }
    public static userfeedback.Math.Rectangle parseFrom(
        java.io.InputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws java.io.IOException {
      return PARSER.parseFrom(input, extensionRegistry);
    }
    public static userfeedback.Math.Rectangle parseDelimitedFrom(java.io.InputStream input)
        throws java.io.IOException {
      return PARSER.parseDelimitedFrom(input);
    }
    public static userfeedback.Math.Rectangle parseDelimitedFrom(
        java.io.InputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws java.io.IOException {
      return PARSER.parseDelimitedFrom(input, extensionRegistry);
    }
    public static userfeedback.Math.Rectangle parseFrom(
        com.google.protobuf.CodedInputStream input)
        throws java.io.IOException {
      return PARSER.parseFrom(input);
    }
    public static userfeedback.Math.Rectangle parseFrom(
        com.google.protobuf.CodedInputStream input,
        com.google.protobuf.ExtensionRegistryLite extensionRegistry)
        throws java.io.IOException {
      return PARSER.parseFrom(input, extensionRegistry);
    }

    public static Builder newBuilder() { return Builder.create(); }
    public Builder newBuilderForType() { return newBuilder(); }
    public static Builder newBuilder(userfeedback.Math.Rectangle prototype) {
      return newBuilder().mergeFrom(prototype);
    }
    public Builder toBuilder() { return newBuilder(this); }

    @java.lang.Override
    protected Builder newBuilderForType(
        com.google.protobuf.GeneratedMessage.BuilderParent parent) {
      Builder builder = new Builder(parent);
      return builder;
    }
    /**
     * Protobuf type {@code userfeedback.Rectangle}
     *
     * <pre>
     * Axis-aligned rectangle in 2D space.
     * </pre>
     */
    public static final class Builder extends
        com.google.protobuf.GeneratedMessage.Builder<Builder>
       implements userfeedback.Math.RectangleOrBuilder {
      public static final com.google.protobuf.Descriptors.Descriptor
          getDescriptor() {
        return userfeedback.Math.internal_static_userfeedback_Rectangle_descriptor;
      }

      protected com.google.protobuf.GeneratedMessage.FieldAccessorTable
          internalGetFieldAccessorTable() {
        return userfeedback.Math.internal_static_userfeedback_Rectangle_fieldAccessorTable
            .ensureFieldAccessorsInitialized(
                userfeedback.Math.Rectangle.class, userfeedback.Math.Rectangle.Builder.class);
      }

      // Construct using userfeedback.Math.Rectangle.newBuilder()
      private Builder() {
        maybeForceBuilderInitialization();
      }

      private Builder(
          com.google.protobuf.GeneratedMessage.BuilderParent parent) {
        super(parent);
        maybeForceBuilderInitialization();
      }
      private void maybeForceBuilderInitialization() {
        if (com.google.protobuf.GeneratedMessage.alwaysUseFieldBuilders) {
        }
      }
      private static Builder create() {
        return new Builder();
      }

      public Builder clear() {
        super.clear();
        left_ = 0F;
        bitField0_ = (bitField0_ & ~0x00000001);
        top_ = 0F;
        bitField0_ = (bitField0_ & ~0x00000002);
        width_ = 0F;
        bitField0_ = (bitField0_ & ~0x00000004);
        height_ = 0F;
        bitField0_ = (bitField0_ & ~0x00000008);
        return this;
      }

      public Builder clone() {
        return create().mergeFrom(buildPartial());
      }

      public com.google.protobuf.Descriptors.Descriptor
          getDescriptorForType() {
        return userfeedback.Math.internal_static_userfeedback_Rectangle_descriptor;
      }

      public userfeedback.Math.Rectangle getDefaultInstanceForType() {
        return userfeedback.Math.Rectangle.getDefaultInstance();
      }

      public userfeedback.Math.Rectangle build() {
        userfeedback.Math.Rectangle result = buildPartial();
        if (!result.isInitialized()) {
          throw newUninitializedMessageException(result);
        }
        return result;
      }

      public userfeedback.Math.Rectangle buildPartial() {
        userfeedback.Math.Rectangle result = new userfeedback.Math.Rectangle(this);
        int from_bitField0_ = bitField0_;
        int to_bitField0_ = 0;
        if (((from_bitField0_ & 0x00000001) == 0x00000001)) {
          to_bitField0_ |= 0x00000001;
        }
        result.left_ = left_;
        if (((from_bitField0_ & 0x00000002) == 0x00000002)) {
          to_bitField0_ |= 0x00000002;
        }
        result.top_ = top_;
        if (((from_bitField0_ & 0x00000004) == 0x00000004)) {
          to_bitField0_ |= 0x00000004;
        }
        result.width_ = width_;
        if (((from_bitField0_ & 0x00000008) == 0x00000008)) {
          to_bitField0_ |= 0x00000008;
        }
        result.height_ = height_;
        result.bitField0_ = to_bitField0_;
        onBuilt();
        return result;
      }

      public Builder mergeFrom(com.google.protobuf.Message other) {
        if (other instanceof userfeedback.Math.Rectangle) {
          return mergeFrom((userfeedback.Math.Rectangle)other);
        } else {
          super.mergeFrom(other);
          return this;
        }
      }

      public Builder mergeFrom(userfeedback.Math.Rectangle other) {
        if (other == userfeedback.Math.Rectangle.getDefaultInstance()) return this;
        if (other.hasLeft()) {
          setLeft(other.getLeft());
        }
        if (other.hasTop()) {
          setTop(other.getTop());
        }
        if (other.hasWidth()) {
          setWidth(other.getWidth());
        }
        if (other.hasHeight()) {
          setHeight(other.getHeight());
        }
        this.mergeUnknownFields(other.getUnknownFields());
        return this;
      }

      public final boolean isInitialized() {
        if (!hasLeft()) {
          
          return false;
        }
        if (!hasTop()) {
          
          return false;
        }
        if (!hasWidth()) {
          
          return false;
        }
        if (!hasHeight()) {
          
          return false;
        }
        return true;
      }

      public Builder mergeFrom(
          com.google.protobuf.CodedInputStream input,
          com.google.protobuf.ExtensionRegistryLite extensionRegistry)
          throws java.io.IOException {
        userfeedback.Math.Rectangle parsedMessage = null;
        try {
          parsedMessage = PARSER.parsePartialFrom(input, extensionRegistry);
        } catch (com.google.protobuf.InvalidProtocolBufferException e) {
          parsedMessage = (userfeedback.Math.Rectangle) e.getUnfinishedMessage();
          throw e;
        } finally {
          if (parsedMessage != null) {
            mergeFrom(parsedMessage);
          }
        }
        return this;
      }
      private int bitField0_;

      // required float left = 1;
      private float left_ ;
      /**
       * <code>required float left = 1;</code>
       */
      public boolean hasLeft() {
        return ((bitField0_ & 0x00000001) == 0x00000001);
      }
      /**
       * <code>required float left = 1;</code>
       */
      public float getLeft() {
        return left_;
      }
      /**
       * <code>required float left = 1;</code>
       */
      public Builder setLeft(float value) {
        bitField0_ |= 0x00000001;
        left_ = value;
        onChanged();
        return this;
      }
      /**
       * <code>required float left = 1;</code>
       */
      public Builder clearLeft() {
        bitField0_ = (bitField0_ & ~0x00000001);
        left_ = 0F;
        onChanged();
        return this;
      }

      // required float top = 2;
      private float top_ ;
      /**
       * <code>required float top = 2;</code>
       */
      public boolean hasTop() {
        return ((bitField0_ & 0x00000002) == 0x00000002);
      }
      /**
       * <code>required float top = 2;</code>
       */
      public float getTop() {
        return top_;
      }
      /**
       * <code>required float top = 2;</code>
       */
      public Builder setTop(float value) {
        bitField0_ |= 0x00000002;
        top_ = value;
        onChanged();
        return this;
      }
      /**
       * <code>required float top = 2;</code>
       */
      public Builder clearTop() {
        bitField0_ = (bitField0_ & ~0x00000002);
        top_ = 0F;
        onChanged();
        return this;
      }

      // required float width = 3;
      private float width_ ;
      /**
       * <code>required float width = 3;</code>
       */
      public boolean hasWidth() {
        return ((bitField0_ & 0x00000004) == 0x00000004);
      }
      /**
       * <code>required float width = 3;</code>
       */
      public float getWidth() {
        return width_;
      }
      /**
       * <code>required float width = 3;</code>
       */
      public Builder setWidth(float value) {
        bitField0_ |= 0x00000004;
        width_ = value;
        onChanged();
        return this;
      }
      /**
       * <code>required float width = 3;</code>
       */
      public Builder clearWidth() {
        bitField0_ = (bitField0_ & ~0x00000004);
        width_ = 0F;
        onChanged();
        return this;
      }

      // required float height = 4;
      private float height_ ;
      /**
       * <code>required float height = 4;</code>
       */
      public boolean hasHeight() {
        return ((bitField0_ & 0x00000008) == 0x00000008);
      }
      /**
       * <code>required float height = 4;</code>
       */
      public float getHeight() {
        return height_;
      }
      /**
       * <code>required float height = 4;</code>
       */
      public Builder setHeight(float value) {
        bitField0_ |= 0x00000008;
        height_ = value;
        onChanged();
        return this;
      }
      /**
       * <code>required float height = 4;</code>
       */
      public Builder clearHeight() {
        bitField0_ = (bitField0_ & ~0x00000008);
        height_ = 0F;
        onChanged();
        return this;
      }

      // @@protoc_insertion_point(builder_scope:userfeedback.Rectangle)
    }

    static {
      defaultInstance = new Rectangle(true);
      defaultInstance.initFields();
    }

    // @@protoc_insertion_point(class_scope:userfeedback.Rectangle)
  }

  private static com.google.protobuf.Descriptors.Descriptor
    internal_static_userfeedback_Dimensions_descriptor;
  private static
    com.google.protobuf.GeneratedMessage.FieldAccessorTable
      internal_static_userfeedback_Dimensions_fieldAccessorTable;
  private static com.google.protobuf.Descriptors.Descriptor
    internal_static_userfeedback_Rectangle_descriptor;
  private static
    com.google.protobuf.GeneratedMessage.FieldAccessorTable
      internal_static_userfeedback_Rectangle_fieldAccessorTable;

  public static com.google.protobuf.Descriptors.FileDescriptor
      getDescriptor() {
    return descriptor;
  }
  private static com.google.protobuf.Descriptors.FileDescriptor
      descriptor;
  static {
    java.lang.String[] descriptorData = {
      "\n\035userfeedback/proto/math.proto\022\014userfee" +
      "dback\"+\n\nDimensions\022\r\n\005width\030\001 \002(\002\022\016\n\006he" +
      "ight\030\002 \002(\002\"E\n\tRectangle\022\014\n\004left\030\001 \002(\002\022\013\n" +
      "\003top\030\002 \002(\002\022\r\n\005width\030\003 \002(\002\022\016\n\006height\030\004 \002(" +
      "\002"
    };
    com.google.protobuf.Descriptors.FileDescriptor.InternalDescriptorAssigner assigner =
      new com.google.protobuf.Descriptors.FileDescriptor.InternalDescriptorAssigner() {
        public com.google.protobuf.ExtensionRegistry assignDescriptors(
            com.google.protobuf.Descriptors.FileDescriptor root) {
          descriptor = root;
          internal_static_userfeedback_Dimensions_descriptor =
            getDescriptor().getMessageTypes().get(0);
          internal_static_userfeedback_Dimensions_fieldAccessorTable = new
            com.google.protobuf.GeneratedMessage.FieldAccessorTable(
              internal_static_userfeedback_Dimensions_descriptor,
              new java.lang.String[] { "Width", "Height", });
          internal_static_userfeedback_Rectangle_descriptor =
            getDescriptor().getMessageTypes().get(1);
          internal_static_userfeedback_Rectangle_fieldAccessorTable = new
            com.google.protobuf.GeneratedMessage.FieldAccessorTable(
              internal_static_userfeedback_Rectangle_descriptor,
              new java.lang.String[] { "Left", "Top", "Width", "Height", });
          return null;
        }
      };
    com.google.protobuf.Descriptors.FileDescriptor
      .internalBuildGeneratedFileFrom(descriptorData,
        new com.google.protobuf.Descriptors.FileDescriptor[] {
        }, assigner);
  }

  // @@protoc_insertion_point(outer_class_scope)
}
