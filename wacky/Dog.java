/* a java extension */
public class Dog {
	
	String name;
	String breed;
	String color;
	int age;

	public Dog( String name, String breed, String color, int age ) {
		this.name = name;
		this.breed = breed;
		this.age = age;
		this.color = color;	
	}

	public String getName() {
		return name;
	}

	public String getBreed() {
		return breed;
	}

	public int getAge() {
		return age;
	}

	public String getColor() {
		return color;
	}

}
