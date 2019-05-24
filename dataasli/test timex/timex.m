amg = imread('1.jpeg'); % 1.jpg is one of 10 images
[a,b,c]=size(amg); 
dst_img=zeros(a,b,c); 
for k=1:9
    filename=[num2str(k), '.jpeg'];
    d=imread(filename, 'jpeg');
    dst_img=dst_img+double(d);
end

dst_img=dst_img/k;

dst_img=uint8(dst_img);
figure;imshow(dst_img);title('Average'); 
